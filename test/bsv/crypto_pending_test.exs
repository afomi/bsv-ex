defmodule BSV.CryptoPendingTest do
  use ExUnit.Case, async: true

  import Bitwise

  alias BSV.{
    Address,
    Hash,
    KeyPair,
    OutPoint,
    PrivKey,
    PubKey,
    Script,
    Sig,
    Tx,
    TxBuilder,
    TxIn,
    TxOut,
    UTXO,
    VarInt
  }

  alias BSV.Contract.{OpReturn, P2PKH}
  alias Curvy.Curve

  describe "additional crypto coverage" do
    setup do
      compressed_privkey =
        PrivKey.from_wif!("KyGHAK8MNohVPdeGPYXveiAbTfLARVrQuJVtd3qMqN41UEnTWDkF")

      uncompressed_privkey =
        PrivKey.from_wif!("5JH9eTJyj6bYopGhBztsDd4XvAbFNQkpZEw8AXYoQePtK1r86nu")

      keypair = KeyPair.from_privkey(compressed_privkey)

      locking_script = %Script{
        chunks: [
          :OP_DUP,
          :OP_HASH160,
          <<47, 105, 50, 137, 102, 179, 60, 141, 131, 76, 2, 71, 24, 254, 231, 1, 101, 139, 55,
            71>>,
          :OP_EQUALVERIFY,
          :OP_CHECKSIG
        ]
      }

      prev_txout = %TxOut{satoshis: 50_000, script: locking_script}
      prev_tx = %Tx{outputs: [prev_txout]}

      txin = %TxIn{
        outpoint: %OutPoint{hash: Tx.get_hash(prev_tx), vout: 0},
        script: %Script{}
      }

      change_output = %TxOut{satoshis: 40_000, script: locking_script}

      data_output = %TxOut{
        satoshis: 10_000,
        script: %Script{chunks: [:OP_FALSE, :OP_RETURN, "memo"]}
      }

      tx = %Tx{inputs: [txin], outputs: [change_output, data_output]}
      utxo = UTXO.from_tx(prev_tx, 0)

      {:ok,
       compressed_privkey: compressed_privkey,
       uncompressed_privkey: uncompressed_privkey,
       keypair: keypair,
       prev_txout: prev_txout,
       tx: tx,
       utxo: utxo,
       change_output: change_output,
       pubkey: PubKey.from_privkey(compressed_privkey)}
    end

    test "Sig.sign/5 produces deterministic low-s signatures when RFC6979 nonce derivation is used",
         %{
           compressed_privkey: privkey,
           prev_txout: prev_txout,
           tx: tx
         } do
      signature = Sig.sign(tx, 0, prev_txout, privkey)
      assert Sig.sign(tx, 0, prev_txout, privkey) == signature

      <<0x30, _total_len, 0x02, r_len, _r::binary-size(r_len), 0x02, s_len, s::binary-size(s_len),
        sighash_flag>> = signature

      half_order = div(Curve.secp256k1()[:n], 2)
      s_value = :binary.decode_unsigned(s)

      assert s_value <= half_order
      assert sighash_flag == Sig.sighash_flag(:default)
    end

    test "Sig.sighash/4 handles SIGHASH_NONE by zeroing outputs and sequences", %{
      tx: tx,
      prev_txout: prev_txout
    } do
      script_binary = prev_txout.script |> Script.to_binary() |> VarInt.encode_binary()
      sighash_type = Sig.sighash_flag(:sighash_none) ||| Sig.sighash_flag(:sighash_forkid)
      preimage = Sig.preimage(tx, 0, prev_txout, sighash_type)

      <<_version::little-32, _prevouts::binary-size(32), sequence_hash::binary-size(32),
        _outpoint::binary-size(36), rest::binary>> = preimage

      <<^script_binary::binary-size(byte_size(script_binary)), tail::binary>> = rest

      <<_amount::little-64, _sequence::little-32, outputs_hash::binary-size(32),
        _lock_time::little-32, _flag::little-32>> = tail

      zero = :binary.copy(<<0>>, 32)
      assert sequence_hash == zero
      assert outputs_hash == zero
    end

    test "Sig.sighash/4 supports SIGHASH_SINGLE|ANYONECANPAY", %{
      tx: tx,
      prev_txout: prev_txout
    } do
      script_binary = prev_txout.script |> Script.to_binary() |> VarInt.encode_binary()

      sighash_type =
        Sig.sighash_flag(:sighash_single) ||| Sig.sighash_flag(:sighash_anyonecanpay) |||
          Sig.sighash_flag(:sighash_forkid)

      preimage = Sig.preimage(tx, 0, prev_txout, sighash_type)

      <<_version::little-32, prevouts_hash::binary-size(32), sequence_hash::binary-size(32),
        _outpoint::binary-size(36), rest::binary>> = preimage

      <<^script_binary::binary-size(byte_size(script_binary)), tail::binary>> = rest

      <<_amount::little-64, _sequence::little-32, outputs_hash::binary-size(32),
        _lock_time::little-32, _flag::little-32>> = tail

      expected_output_hash =
        tx.outputs
        |> Enum.at(0)
        |> TxOut.to_binary()
        |> Hash.sha256_sha256()

      zero = :binary.copy(<<0>>, 32)

      assert prevouts_hash == zero
      assert sequence_hash == zero
      assert outputs_hash == expected_output_hash
    end

    test "Sig.verify/5 rejects signatures when the covered subscript mutates", %{
      compressed_privkey: privkey,
      prev_txout: prev_txout,
      tx: tx,
      pubkey: pubkey
    } do
      signature = Sig.sign(tx, 0, prev_txout, privkey)
      assert Sig.verify(signature, tx, 0, prev_txout, pubkey)

      %TxOut{} = prev_txout = prev_txout
      %Script{} = prev_script = prev_txout.script

      mutated_script = %Script{
        prev_script
        | chunks: [
            :OP_DUP,
            :OP_HASH160,
            :binary.copy(<<0>>, 20),
            :OP_EQUALVERIFY,
            :OP_CHECKSIG
          ]
      }

      mutated_txout = %TxOut{prev_txout | script: mutated_script}
      refute Sig.verify(signature, tx, 0, mutated_txout, pubkey)
    end

    test "KeyPair.from_privkey/1 round-trips through PubKey serialization for compressed and uncompressed keys",
         %{
           compressed_privkey: compressed_privkey,
           uncompressed_privkey: uncompressed_privkey
         } do
      %KeyPair{pubkey: compressed_pubkey} = KeyPair.from_privkey(compressed_privkey)
      %KeyPair{pubkey: uncompressed_pubkey} = KeyPair.from_privkey(uncompressed_privkey)

      compressed_roundtrip =
        compressed_pubkey
        |> PubKey.to_binary()
        |> PubKey.from_binary!()

      uncompressed_roundtrip =
        uncompressed_pubkey
        |> PubKey.to_binary(encoding: :hex)
        |> PubKey.from_binary!(encoding: :hex)

      assert compressed_roundtrip.point == compressed_pubkey.point
      assert compressed_roundtrip.compressed

      assert uncompressed_roundtrip.point == uncompressed_pubkey.point
      refute uncompressed_roundtrip.compressed
    end

    test "TxBuilder integrates Sig.sign/5 to produce spendable P2PKH unlocking scripts", %{
      keypair: keypair,
      utxo: utxo,
      prev_txout: prev_txout
    } do
      address = Address.from_pubkey(keypair.pubkey)

      builder = %TxBuilder{
        inputs: [P2PKH.unlock(utxo, %{keypair: keypair})],
        outputs: [
          P2PKH.lock(25_000, %{address: address}),
          OpReturn.lock(0, %{data: ["memo"]})
        ]
      }

      tx = TxBuilder.to_tx(builder)
      [%TxIn{script: script}] = tx.inputs
      [signature, pubkey_bin] = script.chunks

      pubkey = PubKey.from_binary!(pubkey_bin)
      assert Sig.verify(signature, tx, 0, prev_txout, pubkey)
    end
  end
end
