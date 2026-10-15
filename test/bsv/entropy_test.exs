defmodule BSV.EntropyTest do
  use ExUnit.Case, async: true

  alias BSV.Contract.P2RPH
  alias BSV.{Entropy, ExtKey, KeyPair, Mnemonic, PrivKey, Util}

  defmodule FixedProvider do
    @behaviour BSV.Entropy

    @private_key <<1::unsigned-big-256>>

    @impl true
    def bytes(count), do: {:ok, :binary.copy(<<0x42>>, count)}

    @impl true
    def secp256k1_scalar(purpose) do
      send(self(), {:scalar_purpose, purpose})
      {:ok, @private_key}
    end
  end

  defmodule FailingProvider do
    @behaviour BSV.Entropy

    @impl true
    def bytes(_count), do: {:error, :unavailable}

    @impl true
    def secp256k1_scalar(_purpose), do: {:error, :unavailable}
  end

  defmodule InvalidProvider do
    @behaviour BSV.Entropy

    @impl true
    def bytes(_count), do: {:ok, <<0>>}

    @impl true
    def secp256k1_scalar(_purpose), do: {:ok, <<0::unsigned-big-256>>}
  end

  @opts [entropy_provider: FixedProvider]
  @private_key <<1::unsigned-big-256>>

  describe "bytes/2" do
    test "accepts output from the default OTP provider" do
      assert {:ok, data} = Entropy.bytes(32)
      assert byte_size(data) == 32
    end

    test "uses the explicitly selected provider" do
      assert {:ok, :binary.copy(<<0x42>>, 16)} == Entropy.bytes(16, @opts)
      assert :binary.copy(<<0x42>>, 16) == Entropy.bytes!(16, @opts)
      assert :binary.copy(<<0x42>>, 16) == Util.rand_bytes(16, @opts)
    end

    test "propagates provider errors and fails closed" do
      opts = [entropy_provider: FailingProvider]

      assert {:error, :unavailable} == Entropy.bytes(16, opts)

      assert_raise BSV.EntropyError, ~r/unavailable/, fn ->
        Entropy.bytes!(16, opts)
      end
    end

    test "rejects a provider response of the wrong length" do
      assert {:error, {:invalid_byte_count, 16, 1}} ==
               Entropy.bytes(16, entropy_provider: InvalidProvider)
    end
  end

  describe "secp256k1_scalar/2" do
    test "accepts a scalar from the default OTP provider" do
      assert {:ok, <<scalar::unsigned-big-256>>} = Entropy.secp256k1_scalar(:private_key)
      assert scalar > 0
    end

    test "uses the explicitly selected provider" do
      assert {:ok, @private_key} == Entropy.secp256k1_scalar(:private_key, @opts)
      assert @private_key == Entropy.secp256k1_scalar!(:private_key, @opts)
    end

    test "rejects a scalar outside the curve range" do
      assert {:error, :invalid_secp256k1_scalar} ==
               Entropy.secp256k1_scalar(:private_key, entropy_provider: InvalidProvider)
    end
  end

  describe "entropy consumers" do
    test "route random generation through the selected provider" do
      entropy = :binary.copy(<<0x42>>, 16)
      seed = :binary.copy(<<0x42>>, 64)

      assert Mnemonic.new(128, @opts) == Mnemonic.from_entropy(entropy)
      assert ExtKey.new(@opts) == ExtKey.from_seed!(seed)
      assert %PrivKey{d: @private_key} = PrivKey.new(@opts)
      assert_received {:scalar_purpose, :private_key}

      assert %KeyPair{privkey: %PrivKey{d: @private_key}} = KeyPair.new(@opts)
      assert_received {:scalar_purpose, :private_key}

      assert P2RPH.generate_k(@opts) == @private_key
      assert_received {:scalar_purpose, :signing_nonce}
    end
  end
end
