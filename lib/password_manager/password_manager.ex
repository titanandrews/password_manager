defmodule PasswordManager do
  defmodule Record do
    defstruct title: "", user: "", password: "", notes: ""
  end

  defimpl String.Chars, for: Record do
    def to_string(record) do
      """
      Title: #{record.title}
      User name: #{record.user}
      Password: #{record.password}
      Notes: #{record.notes}
      """
    end
  end

  @db_file_name  "password_manager.db"
  @tmp_db_file_name  "password_manager.db.tmp"

  def search(records, key) do
    lower_key = String.downcase(key)
    Enum.filter(records, fn(x) -> String.downcase(x.title) |> String.contains?(lower_key) ||
                                  String.downcase(x.notes) |> String.contains?(lower_key)
                                end)
  end

  def duplicate?(records, title) do
    lower_title = String.downcase(title)
    filtered = Enum.filter(records, fn(x) -> String.downcase(x.title) == lower_title end)
    !Enum.empty?(filtered)
  end

  def find_index(records, title) do
    lower_title = String.downcase(title)
    Enum.find_index(records, fn(x) -> String.downcase(x.title) == lower_title end)
  end

  def update(records, idx, key, new_val) do
    record = Enum.at(records, idx)
    record = Map.update!(record, key, fn(val) -> new_val end)
    List.update_at(records, idx, fn(val) -> record end)
  end

  # Saves the Records to a file and encrypts with openssl 256 AES.
  # Returns :ok or {:error, reason}
  def save(records, pass_phrase, file_name \\ @db_file_name) do
    case File.write(@tmp_db_file_name, :erlang.term_to_binary(records)) do
      :ok ->
        encrypt(@tmp_db_file_name, file_name, pass_phrase)
      {:error, reason} ->
        {:error, "Unable to save. Could not write to temp file #{@tmp_db_file_name} #{reason}"}
    end
  end

  # Decrypts and loads the Records from file.
  # Returns the Records or {:error, reason}
  # Returns empty list if the file does not exist.
  def load(pass_phrase, file_name \\ @db_file_name) do
    case File.exists?(file_name) do
      true ->
        case decrypt(file_name, @tmp_db_file_name, pass_phrase) do
          :ok ->
            records = File.read!(@tmp_db_file_name) |> :erlang.binary_to_term
            File.rm(@tmp_db_file_name)
            records
          {:error, reason} ->
            {:error, "Unable to load. #{reason}"}
          end
      false ->
        []
    end
  end

  defp encrypt(in_file, out_file, pass_phrase) do
    try do
      System.cmd("openssl", ["enc", "-aes-256-cbc", "-k", "#{pass_phrase}",
                             "-in", "#{in_file}", "-out", "#{out_file}"])
      File.rm(in_file)
      :ok
    rescue e in ErlangError -> e
      {:error, "Could not encrypt file #{in_file} #{ErlangError.message(e)}"}
    end
  end

  defp decrypt(in_file, out_file, pass_phrase) do
    try do
      case System.cmd("openssl", ["enc", "-aes-256-cbc", "-d", "-k", "#{pass_phrase}",
                                  "-in", "#{in_file}", "-out", "#{out_file}"]) do
        {_, 0} ->
          :ok
        {_, exit_code} ->
          {:error, "Could not decrypt file #{in_file}"}
      end
    rescue e in ErlangError -> e
      {:error, "Could not decrypt file #{in_file} #{ErlangError.message(e)}"}
    end
  end
end



