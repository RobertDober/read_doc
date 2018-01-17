defmodule ReadDocTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  
  alias ReadDoc.Options

  test "try to rewrite a read only file" do 
    assert capture_io( :stderr, fn ->
      ReadDoc.rewrite_files({%Options{}, ~w{test_support/READONLY.md}})
    end) == "test_support/READONLY.md: permission denied\n"
  end

  test "rewrite emits warnings" do 
    assert capture_io( :stderr, fn ->
      ReadDoc.rewrite_files({%Options{}, ~w{test_support/MISSING_END.md}})
    end) == "test_support/MISSING_END.md:1 end @doc for Example (opened in line 1) missing\ntest_support/MISSING_END.md:2 end @doc missing for Example (opened in line 1)\ntest_support/MISSING_END.md updated\n"
  end

  test "rewrite emits warnings, unless silenced" do 
    assert capture_io( :stderr, fn ->
      ReadDoc.rewrite_files({%Options{silent: true}, ~w{test_support/MISSING_END.md}})
    end) == ""
  end
end
