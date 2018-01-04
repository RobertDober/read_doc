defmodule ReadDoc.Options do
  defstruct begin_trigger: ~s{\\A \\s* <!-- \\s+ begin \\s @doc \\s ([\\w.?!]+) \\s+ --> \\s* \\z },
            end_trigger: ~s{\\A \\s* <!-- \\s+ end \\s @doc \\s ([\\w.?!]+) \\s+ --> \\s* \\z },
            keep_copy: false,
            silent: false,
            fix_errors: true,
            begin_rgx: nil,
            end_rgx: nil


  @moduledoc """
  Implementing all optional behavior of the ReadDoc app
  """
  @doc """
  Creates an Options struct with dependent fields
  """
  def finalize options do
    %{options | 
       begin_rgx: Regex.compile!(options.begin_trigger, "x"),
       end_rgx: Regex.compile!(options.end_trigger, "x") }
  end

end
