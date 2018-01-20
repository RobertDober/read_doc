defmodule Tasks.ReadDoc do
  alias ReadDoc.Options

  import ReadDoc.FileSaver, only: [maybe_backup_files: 1]
  import ReadDoc.DocExtractor, only: [extract_doc: 1]

  @moduledoc """
  ## Abstract

  Documentation of your project can be extracted into files containing
  markers.

  These markers are

      <!-- begin @doc <ElixirIdentifier> -->

  to mark the start of an inserted docstriang and

      <!-- end @doc <ElixirIdentifier> -->

  to mark the end thereof.

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

  @doc """
  This is the implementation interface of the task, it supports the following options:

  """
  @spec run(list(String.t())) :: :ok
  def run(args) do
    case parse_args(args) |> make_options() do
      {:ok, options_and_files} ->
        options_and_files
        |> maybe_backup_files()
        |> ReadDoc.rewrite_files()

      _ ->
        :ok
    end
  end

  defp make_options({[help: true], _, _}) do
    IO.puts(:stderr, extract_doc("ReadDoc.Options"))
    {:exit, nil}
  end

  defp make_options({options, files, []}) do
    {:ok,
     {options
      |> Enum.into(%Options{}), files}}
  end

  defp make_options({_, _, errors}) do
    raise ArgumentError, "undefined switches #{readable_options(errors, [])}"
  end

  defp readable_options([], result), do: result |> Enum.reverse() |> Enum.join(", ")

  defp readable_options([{option, value} | rest], result) do
    readable_options(rest, ["#{option} #{value}" |> String.trim() | result])
  end

  defp parse_args(args) do
    OptionParser.parse(args, strict: switches(), aliases: aliases())
  end

  defp switches,
    do: [
      keep_copy: :boolean,
      start_comment: :string,
      end_comment: :string,
      line_comment: :string,
      help: :boolean
    ]

  defp aliases, do: [k: :keep_copy, h: :help]
end
