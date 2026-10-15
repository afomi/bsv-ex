defmodule BSV.SigTest do
  use ExUnit.Case, async: true
  alias BSV.Sig
  alias BSV.{OutPoint, PrivKey, PubKey, Script, Tx, TxIn, TxOut, Util}

  @prev_txout %TxOut{
    satoshis: 50000,
    script: %Script{chunks: [
      :OP_DUP,
      :OP_HASH160,
      <<47, 105, 50, 137, 102, 179, 60, 141, 131, 76, 2, 71, 24, 254, 231, 1, 101, 139, 55, 71>>,
      :OP_EQUALVERIFY,
      :OP_CHECKSIG
    ]}
  }
  @prev_tx %Tx{outputs: [@prev_txout]}
  @test_txin %TxIn{
    outpoint: %OutPoint{
      hash: Tx.get_hash(@prev_tx),
      vout: 0
    },
    script: %Script{}
  }
  @test_tx %Tx{inputs: [@test_txin]}
  @test_sighash "b8424e696736e3c45eb2da7d0d61bc3571ebdc977aea5cc764229c1f3c3d173b"
  @test_privkey PrivKey.from_wif!("KyGHAK8MNohVPdeGPYXveiAbTfLARVrQuJVtd3qMqN41UEnTWDkF")
  @test_signature "MEUCIQDjRz9K3GUXhKU2HV3/fQXIz6L4+A6RxKKEsL+N4CPgCAIgSI6qg/XCyTsqNLWIG77OrKobfBsDt95g71EnSbSh3DZB"
  @vectors_abc File.read!("test/vectors/sighash.abc.json") |> Jason.decode!()
  @vectors_btc File.read!("test/vectors/sighash.btc.json") |> Jason.decode!()
  @chronicle_fixture File.read!("test/vectors/sighash.chronicle.json") |> Jason.decode!()

  doctest Sig

  describe "sighash_chronicle? guard" do
    test "returns the Chronicle sighash flag" do
      assert Sig.sighash_flag(:sighash_chronicle) == 0x20
    end

    test "detects the Chronicle bit" do
      assert Sig.sighash_chronicle?(0x20)
    end

    test "does not confuse the ForkID bit with Chronicle" do
      refute Sig.sighash_chronicle?(0x40)
    end

    test "detects Chronicle when combined with ForkID" do
      assert Sig.sighash_chronicle?(0x60)
    end
  end

  describe "Sig.otda_preimage/4" do
    test "matches Bitcoin SV node vectors for Chronicle sighash modes" do
      tx = Tx.from_binary!(@chronicle_fixture["raw_tx"], encoding: :hex)
      script = Script.from_binary!(@chronicle_fixture["script"], encoding: :hex)
      txout = %TxOut{satoshis: @chronicle_fixture["satoshis"], script: script}
      vin = @chronicle_fixture["vin"]

      for vector <- @chronicle_fixture["vectors"] do
        preimage =
          Sig.otda_preimage(tx, vin, txout, vector["sighash_type"])
          |> Base.encode16(case: :lower)

        assert preimage == vector["preimage"], vector["name"]
      end
    end
  end

  describe "Chronicle sighash dispatch" do
    test "routes Chronicle combinations to OTDA" do
      tx = Tx.from_binary!(@chronicle_fixture["raw_tx"], encoding: :hex)
      script = Script.from_binary!(@chronicle_fixture["script"], encoding: :hex)
      txout = %TxOut{satoshis: @chronicle_fixture["satoshis"], script: script}
      vin = @chronicle_fixture["vin"]

      for vector <- @chronicle_fixture["vectors"] do
        preimage =
          Sig.preimage(tx, vin, txout, vector["sighash_type"])
          |> Base.encode16(case: :lower)

        sighash =
          Sig.sighash(tx, vin, txout, vector["sighash_type"])
          |> Base.encode16(case: :lower)

        assert preimage == vector["preimage"], vector["name"]
        assert sighash == vector["sighash"], vector["name"]
      end
    end

    test "keeps ForkID without Chronicle on the BIP143 path" do
      tx = Tx.from_binary!(@chronicle_fixture["raw_tx"], encoding: :hex)
      script = Script.from_binary!(@chronicle_fixture["script"], encoding: :hex)
      txout = %TxOut{satoshis: @chronicle_fixture["satoshis"], script: script}
      control = @chronicle_fixture["forkid_control"]

      sighash =
        Sig.sighash(tx, @chronicle_fixture["vin"], txout, control["sighash_type"])
        |> Base.encode16(case: :lower)

      assert sighash == control["sighash"]
    end

    test "returns the historical hash-one result for an out-of-range OTDA input" do
      assert Sig.sighash(@test_tx, 1, @prev_txout, 0x61) == <<1, 0::size(248)>>
    end

    test "returns the historical hash-one result for SIGHASH_SINGLE without a matching output" do
      assert Sig.sighash(@test_tx, 0, @prev_txout, 0x63) == <<1, 0::size(248)>>
    end

    test "signs and verifies with a Chronicle sighash suffix" do
      signature = Sig.sign(@test_tx, 0, @prev_txout, @test_privkey, sighash_type: 0x61)

      assert :binary.last(signature) == 0x61
      assert Sig.verify(
        signature,
        @test_tx,
        0,
        @prev_txout,
        PubKey.from_privkey(@test_privkey)
      )
    end
  end

  describe "Sig.sighash/4" do
    test "must return the correct sighash" do
      sighash = Sig.sighash(@test_tx, 0, @prev_txout, 65)
      |> Util.encode(:hex)
      assert sighash == @test_sighash
    end

    test "Bitcoin ABC test vectors" do
      [_ | vectors] = @vectors_abc

      # This corpus predates Chronicle, when the reserved 0x20 bit was ignored.
      # Chronicle-bearing values are covered by the current BSV node vectors.
      vectors = Enum.reject(vectors, fn
        [_rawtx, _script, _vin, sighash_type, _sighash] ->
          Sig.sighash_chronicle?(sighash_type)

        _comment ->
          false
      end)

      for [rawtx, script, vin, sighash_type, sighash] <- vectors do
        tx = Tx.from_binary!(rawtx, encoding: :hex)
        subscript = Script.from_binary!(script, encoding: :hex)
        txout = %TxOut{script: subscript}

        res = Sig.sighash(tx, vin, txout, sighash_type)
        |> Util.reverse_bin()
        |> Base.encode16(case: :lower)
        assert res == sighash
      end
    end

    # need to implement Flags SCRIPT_ENABLE_SIGHASH_FORKID so can force legacy sighash
    @tag :pending
    test "Bitcoin Core test vectors" do
      [_ | vectors] = @vectors_btc
      for [rawtx, script, vin, sighash_type, sighash] <- vectors do
        tx = Tx.from_binary!(rawtx, encoding: :hex)
        subscript = Script.from_binary!(script, encoding: :hex)
        txout = %TxOut{script: subscript}

        res = Sig.sighash(tx, vin, txout, sighash_type)
        |> Util.reverse_bin()
        |> Base.encode16(case: :lower)
        assert res == sighash
      end
    end
  end

  describe "Sig.sign/5" do
    test "must return the correct signature" do
      signature = Sig.sign(@test_tx, 0, @prev_txout, @test_privkey)
      assert is_binary(signature)
      assert Base.encode64(signature) == @test_signature
    end
  end

  describe "Sig.verify/5" do
    test "must verify the signature" do
      assert Sig.verify(@test_signature, @test_tx, 0, @prev_txout, PubKey.from_privkey(@test_privkey))
    end
  end

end
