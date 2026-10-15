defmodule BSV.Entropy do
  @moduledoc """
  Boundary for security-sensitive random data and private-key generation.

  The default provider is `BSV.Entropy.OTP`, which uses Erlang/OTP's `:crypto`
  application. Callers with additional assurance requirements can pass an
  `:entropy_provider` option implementing this module's behaviour.

  Provider selection is deliberately scoped to each operation. There is no
  application-global provider setting that one wallet or test process can
  silently change for another.

  An alternative provider is part of the application's trusted computing
  base: predictable or repeated output can disclose private keys. Test
  providers must never be selected in production.
  """

  @typedoc "Module implementing the entropy provider callbacks"
  @type provider() :: module()

  @typedoc "Options accepted by entropy-consuming operations"
  @type option() :: {:entropy_provider, provider()}
  @type options() :: [option()]

  @typedoc "Security-sensitive purpose for which a curve scalar is requested"
  @type scalar_purpose() :: :private_key | :signing_nonce

  @type reason() ::
          term()
          | {:invalid_byte_count, non_neg_integer(), non_neg_integer()}
          | :invalid_secp256k1_scalar
          | {:invalid_provider_response, term()}
          | {:provider_exception, Exception.t()}
          | {:provider_failure, atom(), term()}

  @callback bytes(non_neg_integer()) :: {:ok, binary()} | {:error, term()}
  @callback secp256k1_scalar(scalar_purpose()) :: {:ok, <<_::256>>} | {:error, term()}

  @default_provider BSV.Entropy.OTP
  @secp256k1_order 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

  @doc """
  Returns the requested number of cryptographically secure random bytes.
  """
  @spec bytes(non_neg_integer(), options()) :: {:ok, binary()} | {:error, reason()}
  def bytes(count, opts \\ []) when is_integer(count) and count >= 0 do
    provider = provider(opts)

    provider
    |> invoke(:bytes, [count])
    |> validate_bytes(count)
  end

  @doc """
  Returns the requested number of cryptographically secure random bytes or
  raises `BSV.EntropyError` when the provider fails.
  """
  @spec bytes!(non_neg_integer(), options()) :: binary()
  def bytes!(count, opts \\ []) do
    case bytes(count, opts) do
      {:ok, data} -> data
      {:error, reason} -> raise BSV.EntropyError, reason
    end
  end

  @doc """
  Returns a uniformly generated scalar for the `secp256k1` curve.

  The purpose is supplied to the provider so deployments can apply distinct
  policy or audit handling to private keys and signing nonces.
  """
  @spec secp256k1_scalar(scalar_purpose(), options()) ::
          {:ok, <<_::256>>} | {:error, reason()}
  def secp256k1_scalar(purpose, opts \\ []) when purpose in [:private_key, :signing_nonce] do
    opts
    |> provider()
    |> invoke(:secp256k1_scalar, [purpose])
    |> validate_secp256k1_scalar()
  end

  @doc """
  Returns a uniformly generated scalar for the `secp256k1` curve or
  raises `BSV.EntropyError` when the provider fails.
  """
  @spec secp256k1_scalar!(scalar_purpose(), options()) :: <<_::256>>
  def secp256k1_scalar!(purpose, opts \\ []) do
    case secp256k1_scalar(purpose, opts) do
      {:ok, scalar} -> scalar
      {:error, reason} -> raise BSV.EntropyError, reason
    end
  end

  defp provider(opts), do: Keyword.get(opts, :entropy_provider, @default_provider)

  defp invoke(provider, function, arguments) when is_atom(provider) do
    try do
      apply(provider, function, arguments)
    rescue
      exception -> {:error, {:provider_exception, exception}}
    catch
      kind, reason -> {:error, {:provider_failure, kind, reason}}
    end
  end

  defp invoke(provider, _function, _arguments),
    do: {:error, {:invalid_provider_response, provider}}

  defp validate_bytes({:ok, data}, count) when is_binary(data) do
    case byte_size(data) do
      ^count -> {:ok, data}
      actual -> {:error, {:invalid_byte_count, count, actual}}
    end
  end

  defp validate_bytes({:error, reason}, _count), do: {:error, reason}

  defp validate_bytes(response, _count),
    do: {:error, {:invalid_provider_response, response}}

  defp validate_secp256k1_scalar({:ok, <<scalar::unsigned-big-256>> = scalar_binary})
       when scalar > 0 and scalar < @secp256k1_order,
       do: {:ok, scalar_binary}

  defp validate_secp256k1_scalar({:ok, _scalar}),
    do: {:error, :invalid_secp256k1_scalar}

  defp validate_secp256k1_scalar({:error, reason}), do: {:error, reason}

  defp validate_secp256k1_scalar(response),
    do: {:error, {:invalid_provider_response, response}}
end
