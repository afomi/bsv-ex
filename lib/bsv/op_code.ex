defmodule BSV.OpCode do
  @moduledoc """
  Module for accessing Bitcoin Script Op Codes.

  Bitcoin Script provides a number of operations or commands, known as Op Codes.
  When the script is evaluated, the Op Codes manipulate the stack in some way.

  Within a script, an Op Code is single byte integer. Op Codes can also be
  referenced by an atom representing the word or name of the Op Code.
  """

  @typedoc """
  Op Code

  Represented as either an `t:atom/0` or an `t:integer/0`.
  """
  @type t() :: atom() | integer()

  @op_codes %{
    # push value
    OP_0: 0,
    OP_FALSE: 0,

    OP_PUSHBYTES_1: 1,
    OP_PUSHBYTES_2: 2,
    OP_PUSHBYTES_3: 3,
    OP_PUSHBYTES_4: 4,
    OP_PUSHBYTES_5: 5,
    OP_PUSHBYTES_6: 6,
    OP_PUSHBYTES_7: 7,
    OP_PUSHBYTES_8: 8,
    OP_PUSHBYTES_9: 9,
    OP_PUSHBYTES_10: 10,
    OP_PUSHBYTES_11: 11,
    OP_PUSHBYTES_12: 12,
    OP_PUSHBYTES_13: 13,
    OP_PUSHBYTES_14: 14,
    OP_PUSHBYTES_15: 15,
    OP_PUSHBYTES_16: 16,
    OP_PUSHBYTES_17: 17,
    OP_PUSHBYTES_18: 18,
    OP_PUSHBYTES_19: 19,
    OP_PUSHBYTES_20: 20,
    OP_PUSHBYTES_21: 21,
    OP_PUSHBYTES_22: 22,
    OP_PUSHBYTES_23: 23,
    OP_PUSHBYTES_24: 24,
    OP_PUSHBYTES_25: 25,
    OP_PUSHBYTES_26: 26,
    OP_PUSHBYTES_27: 27,
    OP_PUSHBYTES_28: 28,
    OP_PUSHBYTES_29: 29,
    OP_PUSHBYTES_30: 30,
    OP_PUSHBYTES_31: 31,
    OP_PUSHBYTES_32: 32,
    OP_PUSHBYTES_33: 33,
    OP_PUSHBYTES_34: 34,
    OP_PUSHBYTES_35: 35,
    OP_PUSHBYTES_36: 36,
    OP_PUSHBYTES_37: 37,
    OP_PUSHBYTES_38: 38,
    OP_PUSHBYTES_39: 39,
    OP_PUSHBYTES_40: 40,
    OP_PUSHBYTES_41: 41,
    OP_PUSHBYTES_42: 42,
    OP_PUSHBYTES_43: 43,
    OP_PUSHBYTES_44: 44,
    OP_PUSHBYTES_45: 45,
    OP_PUSHBYTES_46: 46,
    OP_PUSHBYTES_47: 47,
    OP_PUSHBYTES_48: 48,
    OP_PUSHBYTES_49: 49,
    OP_PUSHBYTES_50: 50,
    OP_PUSHBYTES_51: 51,
    OP_PUSHBYTES_52: 52,
    OP_PUSHBYTES_53: 53,
    OP_PUSHBYTES_54: 54,
    OP_PUSHBYTES_55: 55,
    OP_PUSHBYTES_56: 56,
    OP_PUSHBYTES_57: 57,
    OP_PUSHBYTES_58: 58,
    OP_PUSHBYTES_59: 59,
    OP_PUSHBYTES_60: 60,
    OP_PUSHBYTES_61: 61,
    OP_PUSHBYTES_62: 62,
    OP_PUSHBYTES_63: 63,
    OP_PUSHBYTES_64: 64,
    OP_PUSHBYTES_65: 65,
    OP_PUSHBYTES_66: 66,
    OP_PUSHBYTES_67: 67,
    OP_PUSHBYTES_68: 68,
    OP_PUSHBYTES_69: 69,
    OP_PUSHBYTES_70: 70,
    OP_PUSHBYTES_71: 71,
    OP_PUSHBYTES_72: 72,
    OP_PUSHBYTES_73: 73,
    OP_PUSHBYTES_74: 74,
    OP_PUSHBYTES_75: 75,

    OP_PUSHDATA1: 76,
    OP_PUSHDATA2: 77,
    OP_PUSHDATA4: 78,
    OP_1NEGATE: 79,
    OP_RESERVED: 80,
    OP_TRUE: 81,
    OP_1: 81,
    OP_2: 82,
    OP_3: 83,
    OP_4: 84,
    OP_5: 85,
    OP_6: 86,
    OP_7: 87,
    OP_8: 88,
    OP_9: 89,
    OP_10: 90,
    OP_11: 91,
    OP_12: 92,
    OP_13: 93,
    OP_14: 94,
    OP_15: 95,
    OP_16: 96,

    # control
    OP_NOP: 97,
    OP_VER: 98,
    OP_IF: 99,
    OP_NOTIF: 100,
    OP_VERIF: 101,
    OP_VERNOTIF: 102,
    OP_ELSE: 103,
    OP_ENDIF: 104,
    OP_VERIFY: 105,
    OP_RETURN: 106,

    # stack ops
    OP_TOALTSTACK: 107,
    OP_FROMALTSTACK: 108,
    OP_2DROP: 109,
    OP_2DUP: 110,
    OP_3DUP: 111,
    OP_2OVER: 112,
    OP_2ROT: 113,
    OP_2SWAP: 114,
    OP_IFDUP: 115,
    OP_DEPTH: 116,
    OP_DROP: 117,
    OP_DUP: 118,
    OP_NIP: 119,
    OP_OVER: 120,
    OP_PICK: 121,
    OP_ROLL: 122,
    OP_ROT: 123,
    OP_SWAP: 124,
    OP_TUCK: 125,

    # splice ops
    OP_CAT: 126,
    OP_SPLIT: 127,
    OP_NUM2BIN: 128,
    OP_BIN2NUM: 129,
    OP_SIZE: 130,

    # bit logic
    OP_INVERT: 131,
    OP_AND: 132,
    OP_OR: 133,
    OP_XOR: 134,
    OP_EQUAL: 135,
    OP_EQUALVERIFY: 136,
    OP_RESERVED1: 137,
    OP_RESERVED2: 138,

    # numeric
    OP_1ADD: 139,
    OP_1SUB: 140,
    OP_2MUL: 141,
    OP_2DIV: 142,
    OP_NEGATE: 143,
    OP_ABS: 144,
    OP_NOT: 145,
    OP_0NOTEQUAL: 146,

    OP_ADD: 147,
    OP_SUB: 148,
    OP_MUL: 149,
    OP_DIV: 150,
    OP_MOD: 151,
    OP_LSHIFT: 152,
    OP_RSHIFT: 153,

    OP_BOOLAND: 154,
    OP_BOOLOR: 155,
    OP_NUMEQUAL: 156,
    OP_NUMEQUALVERIFY: 157,
    OP_NUMNOTEQUAL: 158,
    OP_LESSTHAN: 159,
    OP_GREATERTHAN: 160,
    OP_LESSTHANOREQUAL: 161,
    OP_GREATERTHANOREQUAL: 162,
    OP_MIN: 163,
    OP_MAX: 164,

    OP_WITHIN: 165,

    # crypto
    OP_RIPEMD160: 166,
    OP_SHA1: 167,
    OP_SHA256: 168,
    OP_HASH160: 169,
    OP_HASH256: 170,
    OP_CODESEPARATOR: 171,
    OP_CHECKSIG: 172,
    OP_CHECKSIGVERIFY: 173,
    OP_CHECKMULTISIG: 174,
    OP_CHECKMULTISIGVERIFY: 175,

    OP_CHECKLOCKTIMEVERIFY: 177,
    OP_CHECKSEQUENCEVERIFY: 178,

    # expansion
    OP_NOP1: 176,
    OP_NOP2: 177,
    OP_NOP3: 178,
    OP_NOP4: 179,
    OP_NOP5: 180,
    OP_NOP6: 181,
    OP_NOP7: 182,
    OP_NOP8: 183,
    OP_NOP9: 184,
    OP_NOP10: 185,

    OP_RETURN_187: 187,
    OP_RETURN_188: 188,
    OP_RETURN_189: 189,
    OP_RETURN_190: 190,
    OP_RETURN_191: 191,
    OP_RETURN_192: 192,
    OP_RETURN_193: 193,
    OP_RETURN_194: 194,
    OP_RETURN_195: 195,
    OP_RETURN_196: 196,
    OP_RETURN_197: 197,
    OP_RETURN_198: 198,
    OP_RETURN_199: 199,
    OP_RETURN_200: 200,
    OP_RETURN_201: 201,
    OP_RETURN_202: 202,
    OP_RETURN_203: 203,
    OP_RETURN_204: 204,
    OP_RETURN_205: 205,
    OP_RETURN_206: 206,
    OP_RETURN_207: 207,
    OP_RETURN_208: 208,
    OP_RETURN_209: 209,
    OP_RETURN_210: 210,
    OP_RETURN_211: 211,
    OP_RETURN_212: 212,
    OP_RETURN_213: 213,
    OP_RETURN_214: 214,
    OP_RETURN_215: 215,
    OP_RETURN_216: 216,
    OP_RETURN_217: 217,
    OP_RETURN_218: 218,
    OP_RETURN_219: 219,
    OP_RETURN_220: 220,
    OP_RETURN_221: 221,
    OP_RETURN_222: 222,
    OP_RETURN_223: 223,
    OP_RETURN_224: 224,
    OP_RETURN_225: 225,
    OP_RETURN_226: 226,
    OP_RETURN_227: 227,
    OP_RETURN_228: 228,
    OP_RETURN_229: 229,
    OP_RETURN_230: 230,
    OP_RETURN_231: 231,
    OP_RETURN_232: 232,
    OP_RETURN_233: 233,
    OP_RETURN_234: 234,
    OP_RETURN_235: 235,
    OP_RETURN_236: 236,
    OP_RETURN_237: 237,
    OP_RETURN_238: 238,
    OP_RETURN_239: 239,
    OP_RETURN_240: 240,
    OP_RETURN_241: 241,
    OP_RETURN_242: 242,
    OP_RETURN_243: 243,
    OP_RETURN_244: 244,
    OP_RETURN_245: 245,
    OP_RETURN_246: 246,
    OP_RETURN_247: 247,
    OP_RETURN_248: 248,
    # OP_RETURN_249: 249,
    # OP_RETURN_250: 250,
    # OP_RETURN_251: 251,
    # OP_RETURN_252: 252,
    # OP_RETURN_253: 253,
    # OP_RETURN_254: 254,

    # template matching params
    OP_SMALLDATA: 249,
    OP_SMALLINTEGER: 250,
    OP_PUBKEYS: 251,
    OP_PUBKEYHASH: 253,
    OP_PUBKEY: 254,
    OP_INVALIDOPCODE: 255
  }

  @doc """
  Returns a map of all Op Codes.
  """
  @spec all() :: map()
  def all(), do: @op_codes

  @doc """
  Returns an `t:atom/0` Op Code from the given value. Returns nil if the value
  is not a valid Op Code.

  ## Examples

      iex> BSV.OpCode.to_atom :OP_RETURN
      :OP_RETURN

      iex> BSV.OpCode.to_atom "op_return"
      :OP_RETURN

      iex> BSV.OpCode.to_atom <<106>>
      :OP_RETURN

      iex> BSV.OpCode.to_atom 106
      :OP_RETURN

      iex> BSV.OpCode.to_atom :UNKNOWN_CODE
      nil
  """
  @spec to_atom(atom() | binary() | String.t() | integer()) :: t() | nil
  def to_atom(op) when is_atom(op),
    do: Enum.find_value(@op_codes, fn {k, _v} -> if k == op, do: k end)

  def to_atom(<<op>>) when is_integer(op), do: to_atom(op)

  def to_atom(op) when is_binary(op),
    do: op |> String.upcase() |> String.to_existing_atom()

  def to_atom(0), do: :OP_FALSE

  def to_atom(op) when is_integer(op) and op in 0..255,
    do: Enum.find_value(@op_codes, fn {k, v} -> if v == op, do: k end)

  @doc """
  Returns an `t:atom/0` Op Code from the given value.

  As `to_atom/1` but raises an error if the value is not a valid Op Code.
  """
  @spec to_atom!(atom() | String.t() | binary() | integer()) :: t()
  def to_atom!(op) do
    case to_atom(op) do
      nil -> raise BSV.DecodeError, {:invalid_opcode, op}
      opcode -> opcode
    end
  end

  @doc """
  Returns an `t:integer/0` Op Code from the given value. Returns nil if the
  value is not a valid Op Code.

  ## Examples

      iex> BSV.OpCode.to_integer :OP_RETURN
      106

      iex> BSV.OpCode.to_integer "op_return"
      106

      iex> BSV.OpCode.to_integer <<106>>
      106

      iex> BSV.OpCode.to_integer 106
      106

      iex> BSV.OpCode.to_integer :UNKNOWN_CODE
      nil
  """
  @spec to_integer(atom() | binary() | String.t()) :: t() | nil
  def to_integer(op) when is_atom(op), do: @op_codes[op]

  def to_integer(<<op>>) when is_integer(op), do: op

  def to_integer(op) when is_binary(op),
    do: op |> String.upcase() |> String.to_existing_atom() |> to_integer()

  def to_integer(op) when is_integer(op) and op in 0..255,
    do: Enum.find_value(@op_codes, fn {_k, v} -> if v == op, do: v end)

  @doc """
  Returns an `t:integer/0` Op Code from the given value.

  As `to_integer/1` but raises an error if the value is not a valid Op Code.
  """
  @spec to_integer!(atom() | binary() | String.t()) :: t()
  def to_integer!(op) do
    case to_integer(op) do
      nil -> raise BSV.DecodeError, {:invalid_opcode, op}
      opcode -> opcode
    end
  end

end
