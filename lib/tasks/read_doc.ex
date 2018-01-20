defmodule Tasks.ReadDoc do
  alias ReadDoc.Options

  import ReadDoc.FileSaver, only: [maybe_backup_files: 1]

  @shortdoc """
  Extract ex_doc documentation from modules or functions into a file
  """

  @moduledoc """
  ## Abstract

  Documentation of your project can be extracted into files containing
  markers.

  These markers are a marker to start insertion, which is of the form:

      <!-- begin @doc <ElixirIdentifier> -->

  and

      <!-- end @doc <ElixirIdentifier> -->

  Right now only `@moduledoc`  and `@doc` strings can be extracted, according to
  if `<ElixirIdentifier>` refers to a module or a function.

  E.g. if a file (typically `README.md`) contains the following content:

        Preface
        <!-- begin @doc: My.Module -->
           Some text
        <!-- end @doc: My.Module -->
        Epilogue


  running

        mix read_doc README.md

  will replace `Some text`
  with the moduledoc string of `My.Module`.

  ## Limitations
  
  - Docstrings for types, macros and callbacks cannot be accessed yet.
  - Recursion is not supported, meaning that a docstring containing markers
    will not trigger the inclusion of the docstring indicated by these markers.


  """

  @spec run( list(String.t) ) :: :ok
  def run(args) do
    parse_args(args)
      |> make_options()
      |> maybe_backup_files()
      |> ReadDoc.rewrite_files()
  end


  defp make_options({options, files, []}) do
    { options
        |> Enum.into(%Options{}),
        files }
  end
  defp make_options({_, _, errors}) do
    raise ArgumentError, "undefined switches #{readable_options(errors, [])}"
  end

  defp readable_options([], result), do: result |> Enum.reverse() |> Enum.join(", ")
  defp readable_options([{option, value}|rest], result) do
    readable_options(rest, [ "#{option} #{value}" |> String.trim() | result ])
  end

  defp parse_args(args) do
    OptionParser.parse(args, strict: switches(), aliases: aliases())
  end

  defp switches, do: [keep_copy: :boolean, start_comment: :string, end_comment: :string, line_comment: :string]
  defp aliases,  do: [k: :keep_copy]

end
