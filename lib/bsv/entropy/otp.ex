defmodule BSV.Entropy.OTP do
  @moduledoc """
  Default `BSV.Entropy` provider backed by Erlang/OTP's `:crypto` application.
  """

  @behaviour BSV.Entropy

  @impl true
  def bytes(count) do
    {:ok, :crypto.strong_rand_bytes(count)}
  end

  @impl true
  def secp256k1_scalar(_purpose) do
    {_public_key, private_key} = :crypto.generate_key(:ecdh, :secp256k1)
    {:ok, private_key}
  end
end
