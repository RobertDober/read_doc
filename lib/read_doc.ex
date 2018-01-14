defmodule ReadDoc do
  use ReadDoc.Types

  import ReadDoc.StateMachine, only: [run: 2]
  alias ReadDoc.Options

  @moduledoc """
  Implements reading a file and replacing indicated portions (as defined by `%Options{}` and the
  strings `"begin @doc " docname` and
          `"end @doc " docname` and
  """

  @spec rewrite_files( pair(Options.t, list(String.t)) ) :: :ok
  def rewrite_files({options, files}) do
    options_prime = Options.finalize(options)
    files |> Enum.each(fn file -> rewrite_file(file, options_prime) end)
  end

  @spec rewrite_file( String.t, Options.t ) :: :ok
  defp rewrite_file(file, options) do 
    File.read!(file)
      |> String.split("\n")
      |> run(options)
      |> Enum.join("\n")
      |> write_back(file)
  end

  @spec write_back( String.t, String.t ) :: :ok
  defp write_back(text, file) do 
    IO.puts :stderr,
      (case File.write(file, text) do
        :ok -> "#{file} updated"
        {:error, reason} ->
           "#{file}: #{:file.format_error(reason)}"
      end)
  end

end
