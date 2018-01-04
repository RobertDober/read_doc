defmodule Mix.Tasks.ReadDoc do
  alias ReadDoc.Options

  import ReadDoc.FileSaver, only: [maybe_backup_files: 1]

  @shortdoc """
  Extract ex_doc documentation from modules or functions into a file.
  """

  @moduledoc """
  The documentation to be extracted and its location in the target file
  are indicated by two lines, a start line and an end line which act as
  parentheses that are kept, the lines between them are replaced by the
  doc strings defined by the start and end line's content.
  
  E.g. if a file (typically `README.md` contains the following content:

        Preface
        <!-- begin @doc: My.Module -->
           Some text
        <!-- end @doc: My.Module -->
        Epilogue


  running the `read_doc` task with `README.md`, will replace `Some text`
  with the moduledoc string of `My.Module`.

  Also if the name designates a function, the docsring of the given function
  will be replaced, e.g.

        <!-- begin @doc: My.Module.shiny_fun -->
          ...
        <!-- end @doc: My.Module.shiny_fun -->
  """
  
  use Mix.Task

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
    OptionParser.parse(args, switches: switches(), aliases: aliases())
  end

  defp switches, do: [keep_copy: :boolean, start_comment: :string, end_comment: :string, line_comment: :string]
  defp aliases,  do: [k: :keep_copy]

end
