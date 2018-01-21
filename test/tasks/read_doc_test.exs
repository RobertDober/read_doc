defmodule Mix.Tasks.ReadDocTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Mix.Tasks.ReadDoc, as: T
  
  test "with default args" do 
    assert capture_io( :stderr, fn->
      T.run(~w{test_support/EMPTY.md})
    end) == "test_support/EMPTY.md updated\n"
  end

  test "with illegal args" do 
    assert_raise(ArgumentError, "undefined switches --illegal", fn ->
      T.run(~w{--illegal xxx})
    end)
  end

  test "backing up a file" do 
    assert capture_io(:stderr, fn ->
      T.run(~w{--keep-copy test_support/BUP.md})
    end) == "backing up file test_support/BUP.md -> test_support/BUP.md.bup2\ntest_support/BUP.md updated\n"
    assert File.read("test_support/BUP.md.bup2") == {:ok, "Backed up once\n"}
    File.rm("test_support/BUP.md.bup2")
  end
end

