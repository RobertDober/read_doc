defmodule ReadDoc.Options.CollectableImpl do
  
  defimpl Collectable, for: ReadDoc.Options do
    def into acc do 
      collector = fn
        strct, {:cont, {kw, value}} -> %{strct | kw => value}
        strct, :done                -> strct
        _,     :halt                -> :ok
      end
      { acc, collector }
    end
  
  end
end