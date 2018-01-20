defmodule ReadDoc.Options do
  use ReadDoc.Types

  defstruct begin_trigger: ~s{\\A \\s* <!-- \\s+ begin \\s @doc \\s ([\\w.?!]+) \\s+ --> \\s* \\z },
            end_trigger: ~s{\\A \\s* <!-- \\s+ end \\s @doc \\s ([\\w.?!]+) \\s+ --> \\s* \\z },
            keep_copy: false,
            silent: false,
            fix_errors: true,
            begin_rgx: nil,
            end_rgx: nil

  @type t :: %__MODULE__{begin_trigger: String.t, end_trigger: String.t, keep_copy: boolean, silent: boolean,
                         fix_errors: true, begin_rgx: maybe(Regex.t), end_rgx: maybe(Regex.t)}

  @moduledoc """
  ## Usage:

      mix read_doc [options] files...

  Each file is scanned for block of lines starting with `<!-- begin @doc...` and 
  endifing with `<!-- end @doc...`.
  Then the content between two matching lines is replaced with the corresponding docstring.

  The following options are implemented

      --silent     no messages emitted to :stderr (defaults to false)
      --keep-copy  a copy of the original input file is kept by appending `.bup<n>` where n runs from 1 to the
                   next available number for which no copy exists yet (defaults to false)
      --fix-errors defaults to true! (deactivate via --no-fix-errors), and closing `<!-- end @doc...` lines
                   with no matching `<!-- begin @doc...` are removed from the input
      --begin-trigger defaults to `"\\A \\s* <!-- \\s+ begin \\s @doc \\s ([\\w.?!]+) \\s+ --> \\s* \\z"`.
                      This values is interpreted as an extended regex indicating the begin of a docstring block, where
                      the first capture defines the module/function of the docstring
      --end-trigger defaults to `"\\A \\s* <!-- \\s+ end \\s @doc \\s ([\\w.?!]+) \\s+ --> \\s* \\z"`.
                      This values is interpreted as an extended regex indicating the end of a docstring block, where
                      the first capture defines the module/function of the docstring


  """
  @doc """
  Creates an Options struct with dependent fields
  """
  @spec finalize( t ) :: t
  def finalize options do
    %{options |
       begin_rgx: Regex.compile!(options.begin_trigger, "x"),
       end_rgx: Regex.compile!(options.end_trigger, "x") }
  end

  @spec croak( t, String.t ) :: :ok
  def croak( %__MODULE__{silent: true}, _ ), do: :ok
  def croak( %__MODULE__{silent: false}, message ), do:
    IO.puts :stderr, message
end
