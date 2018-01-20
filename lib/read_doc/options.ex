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
  Implementing all optional behavior of the ReadDoc app
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
