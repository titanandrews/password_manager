defmodule PasswordManager.CLI do

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
      IO.puts "I new it!!"
    end

    defp _find do
      IO.puts "I find it!!"
    end

    defp _delete do
      IO.puts "I delete it!!"
    end

    defp _dump do
      IO.puts "I dump it!!!"
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
    process_input
  end
end