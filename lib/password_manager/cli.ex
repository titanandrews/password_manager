defmodule PasswordManager.CLI do

  defmodule CmdProcessor do
    def accept_cmd("help") do
      _help
    end

    def accept_cmd("h") do
      _help
    end

    def accept_cmd("exit") do
      _exit
    end

    def accept_cmd("x") do
      _exit
    end

    def accept_cmd(x) do
      IO.puts "Don't know how to #{x}\nType help to get help."
    end

    defp _help do
      IO.puts "Commands are:"
      IO.puts "\t(h)elp"
      IO.puts "\te(x)it"
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