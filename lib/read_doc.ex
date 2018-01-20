defmodule ReadDoc do
  use ReadDoc.Types

  import ReadDoc.StateMachine, only: [run!: 3]
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
    case File.read(file) do
      {:ok, content} -> rewrite_existing_file(file, content, options)
      {:error, reason} -> Options.croak options, "#{file}: #{:file.format_error(reason)}"
    end
  end

  @spec rewrite_existing_file( String.t, String.t, Options.t ) :: :ok
  defp rewrite_existing_file(file, content, options) do
    content
      |> String.split("\n")
      |> run!(options, file)
      |> Enum.join("\n")
      |> write_back(file)
      |> file_written_message(file, options)
  end

  @spec write_back( String.t, String.t ) :: :ok | {:error, File.posix()}
  defp write_back(text, file), do: File.write(file, text)


  @spec file_written_message( :ok | {:error, File.posix()}, String.t, Options.t ) :: :ok
  defp file_written_message(:ok, file, options), do:
    Options.croak options, "#{file} updated"
  defp file_written_message({:error, reason}, file, options), do: 
    Options.croak options, "#{file}: #{:file.format_error(reason)}"

end
