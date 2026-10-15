defmodule BSV.DecodeErrorTest do
  use ExUnit.Case, async: true

  # A raw version byte such as <<0x80>> is not valid UTF-8. Interpolating it
  # made the message unprintable, so Logger dropped the whole crash report with
  # "FORMATTER ERROR: bad return value" and the real error was never logged.
  test "an invalid_base58_check message is printable and names the byte in hex" do
    error = BSV.DecodeError.exception({:invalid_base58_check, <<0x80>>, :test})
    message = Exception.message(error)

    assert String.valid?(message)
    assert message == "Invalid version byte `0x80` for network: test"
  end
end
