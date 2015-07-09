defmodule PasswordManager.Util.Test do
  use ExUnit.Case
  test "convert_to_int" do
    assert PasswordManager.Util.convert_to_int("1") == 1
    assert PasswordManager.Util.convert_to_int("x") == {:error, "Not a number."}
    assert PasswordManager.Util.convert_to_int(nil) == {:error, "Not a number."}
    assert PasswordManager.Util.convert_to_int(1) == 1
  end

  test "validate_range" do
    assert PasswordManager.Util.validate_range(1, 1) == {:ok}
    assert PasswordManager.Util.validate_range(0, 2) == {:error, "Number must be from 1 to 2."}
    assert PasswordManager.Util.validate_range(3, 2) == {:error, "Number must be from 1 to 2."}
  end
end