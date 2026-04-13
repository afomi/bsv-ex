defmodule BSV.OpCodeTest do
  use ExUnit.Case, async: true
  alias BSV.OpCode
  doctest OpCode

  describe "OpCode.all/0" do
    test "returns a map of Op Codes" do
      assert is_map(OpCode.all())
    end
  end

  describe "OpCode.to_atom/1" do
    test "converts integers to atoms" do
      assert OpCode.to_atom(0) == :OP_FALSE
      assert OpCode.to_atom(96) == :OP_16
      assert OpCode.to_atom(97) == :OP_NOP
    end

    test "returns nil for push-length bytes 1..75 (not opcodes in Bitcoin SV)" do
      # Bytes 0x01..0x4b are push-length prefixes, not executable opcodes.
      # See bitcoin-sv src/script/opcodes.h — jumps from OP_0 (0x00) to OP_PUSHDATA1 (0x4c).
      assert OpCode.to_atom(1) == nil
      assert OpCode.to_atom(75) == nil
    end

    test "returns CLTV/CSV canonical names for bytes 177/178" do
      # Matches bitcoin-sv opcodes.cpp GetOpName — primary names, not OP_NOP2/NOP3.
      assert OpCode.to_atom(177) == :OP_CHECKLOCKTIMEVERIFY
      assert OpCode.to_atom(178) == :OP_CHECKSEQUENCEVERIFY
    end

    test "returns nil if invalid op code" do
      assert BSV.OpCode.to_atom(186) == nil
    end
  end

  describe "OpCode.to_atom!/1" do
    test "raises error if invalid op code" do
      assert_raise BSV.DecodeError, ~r/invalid op code/i, fn ->
        OpCode.to_atom!(186)
      end
    end
  end

  describe "OpCode.to_integer/1" do
    test "converts integers to atoms" do
      assert OpCode.to_integer(:OP_0) == 0
      assert OpCode.to_integer(:OP_16) == 96
      assert OpCode.to_integer(:OP_NOP) == 97
      assert OpCode.to_integer(:OP_CHECKLOCKTIMEVERIFY) == 177
      assert OpCode.to_integer(:OP_CHECKSEQUENCEVERIFY) == 178
    end

    test "returns nil if invalid op code" do
      assert OpCode.to_integer(:OP_FOO) == nil
    end
  end

  describe "OpCode.to_integer!/1" do
    test "raises error if invalid op code" do
      assert_raise BSV.DecodeError, ~r/invalid op code/i, fn ->
        OpCode.to_integer!(:OP_FOO)
      end
    end
  end


end
