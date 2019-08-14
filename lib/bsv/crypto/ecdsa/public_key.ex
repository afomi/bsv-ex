defmodule BSV.Crypto.ECDSA.PublicKey do
  @moduledoc """
  ECDSA Private Key module.
  """
  defstruct [:point]

  @typedoc "ECDSA Public Key"
  @type t :: %__MODULE__{
    point: binary,
  }

  @typedoc "Erlang ECDSA Public Key sequence"
  @type point :: {
    :ECPoint,
    binary
  }


  @doc """
  Converts the given ECDSA public key struct to an Erlang EC point sequence.

  ## Examples

      iex> public_key = BSV.Crypto.ECDSA.PrivateKey.from_sequence(BSV.Test.ecdsa_key)
      ...> |> BSV.Crypto.ECDSA.PrivateKey.get_public_key
      ...>
      ...> BSV.Crypto.ECDSA.PublicKey.as_sequence(public_key)
      ...> |> is_tuple
      true
  """
  @spec as_sequence(BSV.Crypto.ECDSA.Key.t) :: BSV.Crypto.ECDSA.Key.sequence
  def as_sequence(public_key) do
    {
      :ECPoint,
      public_key.point
    }
  end
  
end