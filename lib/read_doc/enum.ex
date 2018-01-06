defmodule ReadDoc.Enum do
  
  @doc """
  Does pretty much what it has to do, given it's name

      iex> map_reverse([], fn x -> x end)
      []

      iex> map_reverse([1], &(&1 + 1))
      [2]

      iex> map_reverse([1, 2], &(&1 * 2))
      [4, 2]

      iex> map_reverse(1..3, &(&1 - 1))
      [2, 1, 0]

  """
  def map_reverse(coll, fun), do: 
    Enum.reduce(coll, [], fn x, acc -> [fun.(x)|acc] end) 
end
