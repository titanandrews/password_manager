defmodule PasswordManager.Util do
  def convert_to_int(i) do
    unless is_number(i) do
      try do
        idx = String.to_integer(i)
      rescue e in ArgumentError -> e
        {:error, "Not a number."}
      end
    else
      i
    end
  end

  def validate_range(idx, len) do
    if idx in 1..len do
      {:ok}
    else
      {:error, "Number must be from 1 to #{len}."}
    end
  end
end
