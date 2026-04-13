defmodule BSV.Contract.OpCodeHelpersTest do
  use ExUnit.Case, async: true
  alias BSV.Contract.{Helpers, OpCodeHelpers}
  alias BSV.{Contract, VM}

  describe "op_if/3" do
    test "evaluates handle_if if top stack element is true" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<1>>)
      |> OpCodeHelpers.op_if(&Helpers.push(&1, "true"), &Helpers.push(&1, "false"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == ["true"]
    end

    test "evaluates handle_else if top stack element is false" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<0>>)
      |> OpCodeHelpers.op_if(&Helpers.push(&1, "true"), &Helpers.push(&1, "false"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == ["false"]
    end
  end

  describe "op_if/2" do
    test "wraps handle_if with OP_IF and OP_ENDIF — runs body when top is true" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<1>>)
      |> OpCodeHelpers.op_if(&Helpers.push(&1, "body"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == ["body"]
    end

    test "skips body when top is false (leaves stack empty)" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<0>>)
      |> OpCodeHelpers.op_if(&Helpers.push(&1, "body"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == []
    end
  end

  describe "op_notif/2" do
    test "runs body when top is false" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<0>>)
      |> OpCodeHelpers.op_notif(&Helpers.push(&1, "body"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == ["body"]
    end

    test "skips body when top is true" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<1>>)
      |> OpCodeHelpers.op_notif(&Helpers.push(&1, "body"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == []
    end
  end

  describe "generated op_* push functions" do
    test "op_dup/1 pushes the OP_DUP word onto the script" do
      %{script: script} = OpCodeHelpers.op_dup(%Contract{})
      assert script.chunks == [:OP_DUP]
    end

    test "op_checksig/1 pushes OP_CHECKSIG" do
      %{script: script} = OpCodeHelpers.op_checksig(%Contract{})
      assert script.chunks == [:OP_CHECKSIG]
    end
  end

  describe "op_notif/3" do
    test "evaluates handle_if if top stack element is false" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<0>>)
      |> OpCodeHelpers.op_notif(&Helpers.push(&1, "true"), &Helpers.push(&1, "false"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == ["true"]
    end

    test "evaluates handle_else if top stack element is true" do
      %{script: script} = %Contract{}
      |> Helpers.push(<<1>>)
      |> OpCodeHelpers.op_notif(&Helpers.push(&1, "true"), &Helpers.push(&1, "false"))

      assert {:ok, vm} = VM.eval(%VM{}, script)
      assert vm.stack == ["false"]
    end
  end

end
