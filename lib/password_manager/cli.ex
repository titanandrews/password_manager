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

    def accept_cmd("help"), do: _help
    def accept_cmd("h"),    do: _help
    def accept_cmd("exit"), do: _exit
    def accept_cmd("x"),    do: _exit
    def accept_cmd("new"),  do: _new
    def accept_cmd("n"),    do: _new
    def accept_cmd("find"), do: _find
    def accept_cmd("f"),    do: _find
    def accept_cmd("delete"), do: _delete
    def accept_cmd("d"),      do: _delete
    def accept_cmd("dump"),   do: _dump
    def accept_cmd("p"),      do: _dump

    def accept_cmd(x) do
      IO.puts "Don't know how to #{x}\nType help to get help."
    end

    defp _new do
      title = IO.gets(:standard_io, "Title? ") |> String.strip
      # TODO: Check for dups
      user = IO.gets(:standard_io, "User name or id? ") |> String.strip
      password = IO.gets(:standard_io, "Password? ") |> String.strip
      notes = IO.gets(:standard_io, "Notes? ") |> String.strip
      IO.puts "A new record with the following information will be created"
      IO.puts "\tTitle: #{title}"
      IO.puts "\tUser: #{user}"
      IO.puts "\tPassword: #{password}"
      IO.puts "\tNotes: #{notes}"
      confirm = IO.gets(:standard_io, "Confirm yes/no? ") |> String.downcase |>  String.strip
      record = %PasswordManager.Record{title: title, user: user, password: password, notes: notes}
      _save(confirm, record)
    end

    defp _save("yes", record) do
      passwd = _request_passwd
      case PasswordManager.load(passwd) do
        {:error, reason} ->
          IO.puts "Record not saved! #{reason}"
          _reset_passwd
        records ->
          new_records =  Enum.concat(records, [record])
          PasswordManager.save(new_records, passwd)
      end
    end

    defp _save(other, _) do
      IO.puts "Record not saved."
    end

    defp _find do
      IO.puts "I find it!!"
      passwd = _request_passwd
    end

    defp _delete do
      IO.puts "I delete it!!"
      passwd = _request_passwd
    end

    defp _dump do
      IO.puts "I dump it!!!"
      passwd = _request_passwd
    end

    defp _help do
      IO.puts "Commands are:"
      IO.puts "\t(h)elp    --- displays this help"
      IO.puts "\t(n)ew     --- creates a new record"
      IO.puts "\t(f)ind    --- finds a record (searches title and notes and is case insensitive)"
      IO.puts "\t(d)elete  --- deletes a record"
      IO.puts "\tdum(p)    --- displays all records to the console as clear text"
      IO.puts "\te(x)it    --- exits the program"
    end

    defp _exit do
      IO.puts "Goodbye!"
      System.halt
    end

    defp _request_passwd do
      passwd = State.get_passwd
      _process_passwd(passwd)
    end

    defp _process_passwd(nil) do
      passwd = IO.gets(:standard_io, "Enter the master password? ") |> String.strip
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
    input = IO.gets(:standard_io, "?") |> String.downcase |> String.strip
    CmdProcessor.accept_cmd(input)
    process_input
  end

  def main(argv) do
    IO.puts "\n\t\tWelcome to Password Manager!\n"
    File.read!("LICENSE") |> IO.puts
    IO.puts "\tEnter help to see a list of commands"
    State.start_link
    process_input
  end
end