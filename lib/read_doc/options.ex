defmodule ReadDoc.Options do
  defstruct start_comment: ~r{<!-- \s}x,
            end_comment: ~r{\s -->}x,
            line_comment: nil
end
