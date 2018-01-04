defmodule ReadDoc.StateMachineTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  import Support.Helpers

  describe "state machine, nothing to be inserted" do

    test "because empty" do
      assert run([]) == []
    end

    @no_trigger ~w{line_1 line_2}
    test "because no end trigger" do 
      assert run(@no_trigger) == @no_trigger
    end

    @only_end ["<!-- end @doc X -->", "line 1"]
    test "because no begin trigger - warn and autocorrect" do 
      assert capture_io( :stderr, fn ->
        assert run(@only_end) == ["line 1"]
      end) == "ignoring end @doc of X as we are not inside a @doc block\n"
    end

    test "because no begin trigger - warn and do not autocorrect" do 
      assert capture_io( :stderr, fn ->
        assert run(@only_end, fix_errors: false) == @only_end
      end) == "ignoring end @doc of X as we are not inside a @doc block\n"
    end

    test "because no begin trigger - silent and autocorrect" do 
      assert capture_io( :stderr, fn ->
        assert run(@only_end, silent: true) == ["line 1"] 
      end) == ""
    end

    test "because no begin trigger - silent and no autocorrect" do 
      assert capture_io( :stderr, fn ->
        assert run(@only_end, fix_errors: false, silent: true) == @only_end
      end) == ""
    end
  end
  
end
