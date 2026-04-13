defmodule BSV.VarIntTest do
  use ExUnit.Case, async: true
  alias BSV.VarInt
  alias BSV.Tx
  doctest VarInt

  describe "VarInt.encode/1" do
    test "encodes a single-byte int (< 254)" do
      assert VarInt.encode(0) == <<0>>
      assert VarInt.encode(253) == <<253>>
    end

    test "encodes a 2-byte int with 0xFD prefix" do
      assert VarInt.encode(254) == <<253, 254, 0>>
      assert VarInt.encode(0xFFFF) == <<253, 0xFF, 0xFF>>
    end

    test "encodes a 4-byte int with 0xFE prefix" do
      assert VarInt.encode(0x10000) == <<254, 0, 0, 1, 0>>
      assert VarInt.encode(0xFFFFFFFF) == <<254, 0xFF, 0xFF, 0xFF, 0xFF>>
    end

    test "encodes an 8-byte int with 0xFF prefix" do
      assert VarInt.encode(0x100000000) == <<255, 0, 0, 0, 0, 1, 0, 0, 0>>
    end

    test "raises on negative or oversized ints" do
      assert_raise FunctionClauseError, fn -> VarInt.encode(-1) end
      assert_raise FunctionClauseError, fn -> VarInt.encode(0x1_0000_0000_0000_0000) end
    end
  end

  describe "VarInt.decode/1 and decode!/1" do
    test "decode/1 round-trips every size bracket" do
      for int <- [0, 253, 254, 0xFFFF, 0x10000, 0xFFFFFFFF, 0x100000000] do
        assert {:ok, ^int} = int |> VarInt.encode() |> VarInt.decode()
      end
    end

    test "decode/1 returns error tuple on empty binary" do
      assert {:error, :invalid_varint} = VarInt.decode(<<>>)
    end

    test "decode!/1 raises on invalid binary" do
      assert_raise BSV.DecodeError, ~r/invalid varint/i, fn ->
        VarInt.decode!(<<>>)
      end
    end
  end

  describe "VarInt.encode_binary/1 and decode_binary/1" do
    test "round-trips a binary payload" do
      payload = :binary.copy(<<"a">>, 300)
      encoded = VarInt.encode_binary(payload)
      assert <<253, 44, 1, rest::binary>> = encoded
      assert rest == payload
      assert {:ok, ^payload} = VarInt.decode_binary(encoded)
    end

    test "decode_binary!/1 raises when prefix promises more bytes than exist" do
      assert_raise BSV.DecodeError, ~r/invalid varint/i, fn ->
        VarInt.decode_binary!(<<5, "hi">>)
      end
    end
  end

  describe "VarInt.parse_int/1 and parse_data/1" do
    test "parse_int/1 returns the int and remaining bytes for each size bracket" do
      assert {:ok, 42, <<"rest">>} = VarInt.parse_int(<<42, "rest">>)
      assert {:ok, 300, <<"rest">>} = VarInt.parse_int(<<253, 44, 1, "rest">>)
      assert {:ok, 0x10000, <<"rest">>} = VarInt.parse_int(<<254, 0, 0, 1, 0, "rest">>)
      assert {:ok, 0x100000000, <<"rest">>} =
               VarInt.parse_int(<<255, 0, 0, 0, 0, 1, 0, 0, 0, "rest">>)
    end

    test "parse_int/1 errors on empty binary" do
      assert {:error, :invalid_varint} = VarInt.parse_int(<<>>)
    end

    test "parse_data/1 splits the payload from the remainder for 2-byte prefix" do
      payload = :binary.copy(<<"x">>, 300)
      data = VarInt.encode_binary(payload) <> "tail"
      assert {:ok, ^payload, "tail"} = VarInt.parse_data(data)
    end

    test "parse_data/1 errors when the payload is shorter than declared" do
      assert {:error, :invalid_varint} = VarInt.parse_data(<<5, "hi">>)
    end
  end

  describe "VarInt.parse_items/2" do
    test "parses N Serializable items and returns the tail" do
      tx = %Tx{}
      raw_tx = Tx.to_binary(tx)
      data = VarInt.encode(2) <> raw_tx <> raw_tx <> "tail"

      assert {:ok, [%Tx{}, %Tx{}], "tail"} = VarInt.parse_items(data, Tx)
    end

    test "returns an empty list when the count is zero" do
      assert {:ok, [], "tail"} = VarInt.parse_items(<<0, "tail">>, Tx)
    end
  end
end
