defmodule PasswordManager.CLI do

  defmodule State do
    def start_link do
      Agent.start_link(fn -> %{} end, name: __MODULE__)
    end

    def get_passwd do
      Agent.get(__MODULE__, fn map -> Map.get(map, :passwd) end)
    end

    def put_passwd(passwd) do
      Agent.update(__MODULE__, fn map -> Map.put(map, :passwd, passwd) end)
    end
  end

  defmodule CmdProcessor do

    def accept_cmd("help"), do: help()
    def accept_cmd("h"),    do: help()
    def accept_cmd("exit"), do: exit()
    def accept_cmd("x"),    do: exit()
    def accept_cmd("new"),  do: new()
    def accept_cmd("n"),    do: new()
    def accept_cmd("find"), do: find()
    def accept_cmd("f"),    do: find()
    def accept_cmd("delete"), do: delete()
    def accept_cmd("d"),      do: delete()
    def accept_cmd("dump"),   do: dump()
    def accept_cmd("p"),      do: dump()

    def accept_cmd(x) do
      IO.puts "Don't know how to #{x}\nType help to get help."
    end

    def new do
      title = IO.gets(:standard_io, "Title? ") |> String.trim
      user = IO.gets(:standard_io, "User name or id? ") |> String.trim
      password = IO.gets(:standard_io, "Password? ") |> String.trim
      notes = IO.gets(:standard_io, "Notes? ") |> String.trim
      IO.puts "A new record with the following information will be created"
      IO.puts "\tTitle: #{title}"
      IO.puts "\tUser name: #{user}"
      IO.puts "\tPassword: #{password}"
      IO.puts "\tNotes: #{notes}"
      confirm = IO.gets(:standard_io, "Confirm yes/no? ") |> String.downcase
                                                          |>  String.trim
      record = %PasswordManager.Record{title: title, user: user, password: password, notes: notes}
      _save(confirm, record)
    end

    defp _save("yes", record) do
      passwd = _request_passwd()
      case PasswordManager.load(passwd) do
        {:error, reason} ->
          IO.puts "Record not saved! #{reason}"
          _reset_passwd()
        records ->
          case PasswordManager.duplicate?(records, record.title) do
            true ->
              IO.puts "Record not saved!\n" <>
                      "Duplicate record detected. Delete the old one first."
            false ->
              new_records =  Enum.concat(records, [record])
              PasswordManager.save(new_records, passwd)
          end
      end
    end

    defp _save(_, _) do
      IO.puts "Record not saved."
    end

    def find do
      passwd = _request_passwd()
      search_key = IO.gets(:standard_io, "Enter text to search: ") |> String.downcase
                                                                   |>  String.trim
      case PasswordManager.load(passwd) do
        {:error, reason} ->
          IO.puts "Cannot open database #{reason}"
          _reset_passwd()
          []
        all_records ->
          filtered_records = PasswordManager.search(all_records, search_key)
          _list_records(filtered_records)
          {filtered_records, all_records}
      end
    end

    defp _list_records([]) do
      IO.puts "No records found."
    end

    defp _list_records(records) do
      IO.puts "Found #{length(records)} matching entries."
      IO.puts "-----------------------------------------------"
      Enum.each(records, fn(r) -> IO.puts r end)
    end

    defp _get_idx_for_multi_choice_delete(records) do
      titles_with_idx = PasswordManager.make_indexed_titles(records)
      indeces = Map.keys(titles_with_idx)
      indeces = Enum.sort(indeces)
      Enum.each(indeces, fn(i) -> IO.puts "(#{i}) ===> #{titles_with_idx[i]}" end)
      idx = IO.gets(:standard_io, "Enter the number of the record you want to delete: ")
        |> String.downcase
        |>  String.trim
      case PasswordManager.Util.convert_to_int(idx) do
        {:error, msg} ->
          {:error, msg}
        num ->
          case PasswordManager.Util.validate_range(num, length(records)) do
            {:ok} ->
              {num, titles_with_idx[num]}
            {:error, msg} ->
              {:error, msg}
          end
      end
    end

    def delete do
      case find() do
        [] ->
          [] # Do nothing.
        {filtered_records, all_records} ->
          case length(filtered_records) do
            0 -> 0
            1 ->
              idx_for_delete = PasswordManager.find_index(all_records,
                                                          Enum.at(filtered_records, 0).title)
              _try_confirm_delete(all_records, idx_for_delete)
            _ ->
              case _get_idx_for_multi_choice_delete(filtered_records) do
                {:error, msg} ->
                  IO.puts msg
                {_, title} ->
                  idx_for_delete = PasswordManager.find_index(all_records, title)
                  _try_confirm_delete(all_records, idx_for_delete)
              end
          end
      end
    end

    defp _try_confirm_delete(all_records, idx_for_delete) do
      if idx_for_delete != nil do
        record = Enum.at(all_records, idx_for_delete)
        confirm = IO.gets(:standard_io, "The following record will be deleted.\n#{record}" <>
                                        "Confirm yes/no? ") |> String.downcase |>  String.trim
        _do_delete(confirm, all_records, idx_for_delete)
      end
    end

    defp _do_delete("yes", records, idx) do
      records = List.delete_at(records, idx)
      PasswordManager.save(records, _request_passwd())
    end

    defp _do_delete(_, _, _) do
      IO.puts "Nothing deleted."
    end

    def dump do
      passwd = _request_passwd()
      case PasswordManager.load(passwd) do
        {:error, reason} ->
          IO.puts "Cannot open database #{reason}"
          _reset_passwd()
        records ->
          IO.puts "#{length(records)} total entries"
          IO.puts "-----------------------------------------------"
          Enum.each(records, fn(r) -> IO.puts r end)
      end
    end

    def help do
      IO.puts "Commands are:"
      IO.puts "\t(h)elp    --- displays this help"
      IO.puts "\t(n)ew     --- creates a new record"
      IO.puts "\t(f)ind    --- finds a record (searches title and notes and is case insensitive)"
      IO.puts "\t(d)elete  --- deletes a record"
      IO.puts "\tdum(p)    --- displays all records to the console as clear text"
      IO.puts "\te(x)it    --- exits the program"
    end

    def exit do
      IO.puts "Goodbye!"
      System.halt
    end

    defp _request_passwd do
      passwd = State.get_passwd
      _process_passwd(passwd)
    end

    defp _process_passwd(nil) do
      passwd = IO.gets(:standard_io, "Enter the master password? ") |> String.trim
      State.put_passwd(passwd)
      passwd
    end

    defp _process_passwd(passwd) do
      passwd
    end

    defp _reset_passwd do
      State.put_passwd(nil)
    end
  end

  def process_input do
    input = IO.gets(:standard_io, "?") |> String.downcase |> String.trim
    CmdProcessor.accept_cmd(input)
    process_input()
  end

  def exe_path do
    path = System.find_executable("password_manager")
    if path == nil do
      Path.dirname(".")
    else
      Path.dirname(path)
    end
  end

  def main(_) do
    IO.puts "\n\t\tWelcome to Password Manager!\n"
    lic_path = Path.join(exe_path(), "LICENSE")
    File.read!(lic_path) |> IO.puts
    IO.puts "\tEnter help to see a list of commands"
    State.start_link
    process_input()
  end
end