defmodule BSV.MerkleProofTest do
  use ExUnit.Case, async: true
  alias BSV.MerkleProof
  doctest MerkleProof

  @merkle_proof_hex "000cef65a4611570303539143dabd6aa64dbd0f41ed89074406dc0e7cd251cf1efff69f17b44cfe9c2a23285168fe05084e1254daa5305311ed8cd95b19ea6b0ed7505008e66d81026ddb2dae0bd88082632790fc6921b299ca798088bef5325a607efb9004d104f378654a25e35dbd6a539505a1e3ddbba7f92420414387bb5b12fc1c10f00472581a20a043cee55edee1c65dd6677e09903f22992062d8fd4b8d55de7b060006fcc978b3f999a3dbb85a6ae55edc06dd9a30855a030b450206c3646dadbd8c000423ab0273c2572880cdc0030034c72ec300ec9dd7bbc7d3f948a9d41b3621e39"
  @merkle_proof %BSV.MerkleProof{
    flags: 0,
    index: 12,
    nodes: [
      <<142, 102, 216, 16, 38, 221, 178, 218, 224, 189, 136, 8, 38, 50, 121, 15, 198, 146, 27, 41, 156, 167, 152, 8, 139, 239, 83, 37, 166, 7, 239, 185>>,
      <<77, 16, 79, 55, 134, 84, 162, 94, 53, 219, 214, 165, 57, 80, 90, 30, 61, 219, 186, 127, 146, 66, 4, 20, 56, 123, 181, 177, 47, 193, 193, 15>>,
      <<71, 37, 129, 162, 10, 4, 60, 238, 85, 237, 238, 28, 101, 221, 102, 119, 224, 153, 3, 242, 41, 146, 6, 45, 143, 212, 184, 213, 93, 231, 176, 96>>,
      <<111, 204, 151, 139, 63, 153, 154, 61, 187, 133, 166, 174, 85, 237, 192, 109, 217, 163, 8, 85, 160, 48, 180, 80, 32, 108, 54, 70, 218, 219, 216, 192>>,
      <<66, 58, 176, 39, 60, 37, 114, 136, 12, 220, 0, 48, 3, 76, 114, 236, 48, 14, 201, 221, 123, 188, 125, 63, 148, 138, 157, 65, 179, 98, 30, 57>>
    ],
    subject: <<239, 101, 164, 97, 21, 112, 48, 53, 57, 20, 61, 171, 214, 170, 100, 219, 208, 244, 30, 216, 144, 116, 64, 109, 192, 231, 205, 37, 28, 241, 239, 255>>,
    target: <<105, 241, 123, 68, 207, 233, 194, 162, 50, 133, 22, 143, 224, 80, 132, 225, 37, 77, 170, 83, 5, 49, 30, 216, 205, 149, 177, 158, 166, 176, 237, 117>>

  }
  @merkle_root <<112, 47, 97, 187, 145, 58, 194, 6, 62, 15, 42, 237, 109, 147, 61, 51, 134, 35, 77, 165, 200, 235, 158, 48, 228, 152, 239, 210, 95, 183, 203, 150>>

  describe "MerkleProof.from_binary/2" do
    test "parses hex encoded Merkle proof" do
      assert {:ok, proof} = MerkleProof.from_binary(@merkle_proof_hex, encoding: :hex)
      assert proof == @merkle_proof
    end

    test "returns error with invalid proof" do
      assert {:error, _error} = MerkleProof.from_binary("000cef65a4611570303539143dabd6aa64db", encoding: :hex)
    end
  end

  describe "MerkleProof.from_binary!/2" do
    test "parses hex encoded Merkle proof" do
      assert %MerkleProof{} = MerkleProof.from_binary!(@merkle_proof_hex, encoding: :hex)
    end

    test "returns error with invalid proof" do
      assert_raise BSV.DecodeError, ~r/invalid merkle proof/i, fn ->
        MerkleProof.from_binary!("000cef65a4611570303539143dabd6aa64db", encoding: :hex)
      end
    end
  end

  describe "MerkleProof.calc_merkle_root/1" do
    test "calculates the correct merkle proof" do
      assert MerkleProof.calc_merkle_root(@merkle_proof) == @merkle_root
    end
  end

  describe "MerkleProof.to_binary/2" do
    test "serialises the proof as hex string" do
      assert MerkleProof.to_binary(@merkle_proof, encoding: :hex) == @merkle_proof_hex
    end

    test "round-trips a proof whose subject is a full Tx (flag bit 0 set)" do
      tx =
        BSV.Tx.from_binary!(
          "010000000160f61507c2560a0246b53b96e9a8d28f66d82a8b028204b820de6d10c608d8ad030000006a473044022031a761006d72db7a088a4336c50ea4ca5a8aa76cf355e9ae3866ed3994d0748802205abaa90be33ef7211575b933c0f0a688c3ae175ab55cd8e75f0e07364e4e76d6412103d878146ae9f687c95ac05395db7dfdf2698bdc246158f8672257aab631e4c65cffffffff0123020000000000001976a9142eab375745d7799792b5c5f8b5a9406b8ad55bcc88ac00000000",
          encoding: :hex
        )

      proof = %MerkleProof{
        flags: 1,
        index: 0,
        subject: tx,
        target:
          <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0>>,
        nodes: [
          :binary.copy(<<1>>, 32),
          "*",
          :binary.copy(<<2>>, 32)
        ]
      }

      assert {:ok, ^proof} = proof |> MerkleProof.to_binary() |> MerkleProof.from_binary()
    end
  end

  describe "MerkleProof.calc_merkle_root/1 edge cases" do
    test "handles the '*' duplicate-node marker at an even index" do
      tx_hash = :binary.copy(<<0xAA>>, 32)
      sibling = :binary.copy(<<0xBB>>, 32)

      proof = %MerkleProof{index: 0, subject: tx_hash, nodes: ["*", sibling]}

      expected =
        BSV.Hash.sha256_sha256(
          BSV.Hash.sha256_sha256(tx_hash <> tx_hash) <> sibling
        )

      assert MerkleProof.calc_merkle_root(proof) == expected
    end

    test "raises when '*' appears at an odd index (invalid proof shape)" do
      proof = %MerkleProof{
        index: 1,
        subject: :binary.copy(<<0xAA>>, 32),
        nodes: ["*"]
      }

      assert_raise RuntimeError, ~r/invalid nodes/, fn ->
        MerkleProof.calc_merkle_root(proof)
      end
    end

    test "calc_merkle_root/1 accepts a full Tx as the subject" do
      tx = %BSV.Tx{}
      sibling = :binary.copy(<<0xCC>>, 32)
      proof = %MerkleProof{index: 0, subject: tx, nodes: [sibling]}

      expected = BSV.Hash.sha256_sha256(BSV.Tx.get_hash(tx) <> sibling)
      assert MerkleProof.calc_merkle_root(proof) == expected
    end
  end
end
