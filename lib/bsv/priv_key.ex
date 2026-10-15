defmodule BSV.PrivKey do
  @moduledoc """
  A PrivKey is a data structure representing a Bitcoin private key.

  Internally, a private key is a secret 256-bit integer within the range of the
  ECDSA `secp256k1` parmaeters. Each private key corresponds to a public key
  which is a coordinate on the `secp256k1` curve.
  """
  import BSV.Util, only: [decode: 2, encode: 2]
  alias Curvy.Curve

  defstruct d: nil, compressed: true

  @typedoc "Private key struct"
  @type t() :: %__MODULE__{
    d: privkey_bin(),
    compressed: boolean()
  }

  @typedoc "Private key 256-bit binary"
  @type privkey_bin() :: <<_::256>>

  @typedoc """
  Wallet Import Format private key

  WIF encoded keys is a common way to represent private Keys in Bitcoin. WIF
  encoded keys are shorter and include a built-in error checking and a type byte.
  """
  @type privkey_wif() :: String.t()

  @version_bytes %{
    main: <<0x80>>,
    test: <<0xEF>>
  }

  @curve_order Curve.secp256k1()[:n]

  @doc """
  Generates and returns a new `t:BSV.PrivKey.t/0`.

  ## Options

  The accepted options are:

  * `:compressed` - Denotes whether the correspding `t:BSV.PubKey.t/0` is compressed on not. Defaults `true`.
  * `:entropy_provider` - Module implementing the `BSV.Entropy` behaviour. Defaults to `BSV.Entropy.OTP`.
  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    privkey = BSV.Entropy.secp256k1_scalar!(:private_key, opts)
    from_binary!(privkey, opts)
  end

  @doc """
  Parses the given binary into a `t:BSV.PrivKey.t/0`.

  Returns the result in an `:ok` / `:error` tuple pair.

  ## Options

  The accepted options are:

  * `:compressed` - Denotes whether the correspding `t:BSV.PubKey.t/0` is compressed on not. Defaults `true`.
  * `:encoding` - Optionally decode the binary with either the `:base64` or `:hex` encoding scheme.

  ## Examples

      iex> PrivKey.from_binary("3cff04633088622e4599dc2ebf843f82cef3463b910d34a752a13622abae379b", encoding: :hex)
      {:ok, %PrivKey{
        d: <<60, 255, 4, 99, 48, 136, 98, 46, 69, 153, 220, 46, 191, 132, 63, 130, 206, 243, 70, 59, 145, 13, 52, 167, 82, 161, 54, 34, 171, 174, 55, 155>>
      }}
  """
  @spec from_binary(binary(), keyword()) :: {:ok, t()} | {:error, term()}
  def from_binary(privkey, opts \\ []) when is_binary(privkey) do
    encoding = Keyword.get(opts, :encoding)
    compressed = Keyword.get(opts, :compressed, true)

    case decode(privkey, encoding) do
      {:ok, <<_::binary-32>> = decoded} ->
        with :ok <- validate_scalar(decoded) do
          {:ok, struct(__MODULE__, d: decoded, compressed: compressed)}
        end
      {:ok, d} ->
        {:error, {:invalid_privkey, byte_size(d)}}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Parses the given binary into a `t:BSV.PrivKey.t/0`.

  As `from_binary/2` but returns the result or raises an exception.
  """
  @spec from_binary!(binary(), keyword()) :: t()
  def from_binary!(privkey, opts \\ []) when is_binary(privkey) do
    case from_binary(privkey, opts) do
      {:ok, privkey} ->
        privkey
      {:error, error} ->
        raise BSV.DecodeError, error
    end
  end

  @doc """
  Decodes the given `t:BSV.PrivKey.privkey_wif/0` into a `t:BSV.PrivKey.t/0`.

  Returns the result in an `:ok` / `:error` tuple pair.

  ## Examples

      iex> PrivKey.from_wif("KyGHAK8MNohVPdeGPYXveiAbTfLARVrQuJVtd3qMqN41UEnTWDkF")
      {:ok, %PrivKey{
        d: <<60, 255, 4, 99, 48, 136, 98, 46, 69, 153, 220, 46, 191, 132, 63, 130, 206, 243, 70, 59, 145, 13, 52, 167, 82, 161, 54, 34, 171, 174, 55, 155>>
      }}
  """
  @spec from_wif(privkey_wif()) :: {:ok, t()} | {:error, term()}
  def from_wif(wif) when is_binary(wif) do
    version_byte = @version_bytes[BSV.network()]

    case B58.decode58_check(wif) do
      {:ok, {<<d::binary-32, 1>>, ^version_byte}} ->
        with :ok <- validate_scalar(d) do
          {:ok, struct(__MODULE__, d: d, compressed: true)}
        end

      {:ok, {<<d::binary-32>>, ^version_byte}} ->
        with :ok <- validate_scalar(d) do
          {:ok, struct(__MODULE__, d: d, compressed: false)}
        end

      {:ok, {<<d::binary>>, version_byte}} when byte_size(d) in [32,33] ->
        {:error, {:invalid_base58_check, version_byte, BSV.network()}}

      _error ->
        {:error, :invalid_wif}
    end
  end

  @doc """
  Decodes the given `t:BSV.PrivKey.privkey_wif/0` into a `t:BSV.PrivKey.t/0`.

  As `from_wif/1` but returns the result or raises an exception.
  """
  @spec from_wif!(privkey_wif()) :: t()
  def from_wif!(wif) when is_binary(wif) do
    case from_wif(wif) do
      {:ok, privkey} ->
        privkey
      {:error, error} ->
        raise BSV.DecodeError, error
    end
  end

  @doc """
  Serialises the given `t:BSV.PrivKey.t/0` into a binary.

  ## Options

  The accepted options are:

  * `:encoding` - Optionally encode the binary with either the `:base64` or `:hex` encoding scheme.

  ## Examples

      iex> PrivKey.to_binary(@privkey, encoding: :hex)
      "3cff04633088622e4599dc2ebf843f82cef3463b910d34a752a13622abae379b"
  """
  @spec to_binary(t()) :: binary()
  def to_binary(%__MODULE__{d: d}, opts \\ []) do
    encoding = Keyword.get(opts, :encoding)
    encode(d, encoding)
  end

  @doc """
  Encodes the given `t:BSV.PrivKey.t/0` as a `t:BSV.PrivKey.privkey_wif/0`.

  ## Examples

      iex> PrivKey.to_wif(@privkey)
      "KyGHAK8MNohVPdeGPYXveiAbTfLARVrQuJVtd3qMqN41UEnTWDkF"
  """
  @spec to_wif(t()) :: privkey_wif()
  def to_wif(%__MODULE__{d: d, compressed: compressed}) do
    version_byte = @version_bytes[BSV.network()]
    privkey_with_suffix = case compressed do
      true -> <<d::binary, 0x01>>
      false -> d
    end

    B58.encode58_check!(privkey_with_suffix, version_byte)
  end

  defp validate_scalar(<<_::binary-size(32)>> = d) do
    scalar = :binary.decode_unsigned(d)

    cond do
      scalar == 0 -> {:error, :invalid_privkey_scalar}
      scalar >= @curve_order -> {:error, :invalid_privkey_scalar}
      true -> :ok
    end
  end

end
