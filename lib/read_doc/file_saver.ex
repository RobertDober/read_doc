defmodule ReadDoc.FileSaver do
  use ReadDoc.Types
  alias ReadDoc.Options

  @moduledoc """
  Saves all files according to options
  """

  @doc """
  If allowed by options and according to options all files are backed up.
  Currently only one backup method is implemented, which is backing up with the next
  available suffix .bup&lt;nb>
  """
  @spec maybe_backup_files(pair(Options.t, list(String.t))) :: pair(Options.t, list(String.t))
  def maybe_backup_files( params = {options, files}) do 
    if options.keep_copy do
      files |> Enum.each(fn file ->
        backup_file file, options.keep_copy
      end)
    end
    params
  end
  
  @spec next_bup( String.t ) :: String.t
  defp next_bup(file) do 
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map( fn count -> "#{file}.bup#{count}" end )
    |> Stream.drop_while(&File.exists?/1)
    |> Enum.take(1)
    |> hd()
  end

  @spec backup_file( String.t, any ) :: non_neg_integer() | no_return()
  defp backup_file file, _copy_method do 
    File.copy!(file, next_bup(file))
  end
end
