defmodule BSV.VMChronicleVectorsTest do
  use ExUnit.Case, async: true
  alias BSV.{Script, Tx, TxOut, VM}

  # Vectors are extracted from the Bitcoin SV node unit tests. Each fixture
  # names the node version and source file it was taken from.
  @verif File.read!("test/vectors/chronicle.verif.json") |> Jason.decode!()

  defp eval(script_hex, tx_version) do
    script = Script.from_binary!(script_hex, encoding: :hex)
    vm = %VM{ctx: {%Tx{version: tx_version}, 0, %TxOut{satoshis: 0, script: %Script{}}}}
    VM.eval(vm, script)
  end

  # The node fails unbalanced conditionals during evaluation. This VM leaves
  # them open on the if stack, which `VM.valid?/1` rejects.
  defp rejected?({:error, _vm}), do: true
  defp rejected?({:ok, %VM{if_stack: if_stack}}), do: if_stack != []

  defp stack_top_hex(%VM{stack: []}), do: nil
  defp stack_top_hex(%VM{stack: [top | _]}), do: Base.encode16(top, case: :lower)

  describe "OP_VERIF and OP_VERNOTIF node vectors" do
    test "compare the top stack item with the 4-byte little-endian tx version" do
      for v <- @verif["vectors"] do
        result = eval(v["script"], v["tx_version"])
        label = "#{v["case"]} #{v["script"]} (tx version #{v["tx_version"]})"

        if v["error"] do
          assert rejected?(result), label
        else
          assert {:ok, vm} = result, label
          assert vm.if_stack == [], label
          assert length(vm.stack) == v["stack_size"], label
          assert stack_top_hex(vm) == v["stack_top"], label
        end
      end
    end
  end
end
