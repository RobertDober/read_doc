defmodule ReadDoc.StateMachineTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  import Support.Helpers

  describe "state machine, nothing to be inserted" do

    test "because empty" do
      assert run!([]) == []
    end

    @no_trigger ~w{line_1 line_2}
    test "because no end trigger" do
    assert run!(@no_trigger) == @no_trigger
    end

    @only_end ["<!-- end @doc X -->", "line 1"]
    test "because no begin trigger - warn and autocorrect" do
      assert capture_io( :stderr, fn ->
        assert run!(@only_end) == ["line 1"]
      end) == "ignoring end @doc of X as we are not inside a @doc block\n"
    end

    test "because no begin trigger - warn and do not autocorrect" do
      assert capture_io( :stderr, fn ->
        assert run!(@only_end, fix_errors: false) == @only_end
      end) == "ignoring end @doc of X as we are not inside a @doc block\n"
    end

    test "because no begin trigger - silent and autocorrect" do
      assert capture_io( :stderr, fn ->
        assert run!(@only_end, silent: true) == ["line 1"]
      end) == ""
    end

    test "because no begin trigger - silent and no autocorrect" do
      assert capture_io( :stderr, fn ->
        assert run!(@only_end, fix_errors: false, silent: true) == @only_end
      end) == ""
    end
  end

  describe "state machine, insert one doc, no warnings" do
    @only_doc ["<!-- begin @doc Main -->", "<!-- end @doc Main -->"]
    test "only doc" do
      assert capture_io( :stderr, fn ->
        assert run!(@only_doc) == ["<!-- begin @doc Main -->",
         "  This is Main",
         "  This is Main",
         "  This is Main",
         "<!-- end @doc Main -->"]
      end) == ""
    end

    @only_doc_with_removed ["<!-- begin @doc Main.alpha -->", "inside", "still inside", "<!-- end @doc Main.alpha -->"]
    test "only doc with removed" do
      assert capture_io( :stderr, fn ->
        assert run!(@only_doc_with_removed) == ["<!-- begin @doc Main.alpha -->",
         "  This is Main.alpha",
         "<!-- end @doc Main.alpha -->"]
      end) == ""
    end

    @doc_at_beg ["<!-- begin @doc Main -->", "<!-- end @doc Main -->", "after"]
    test "only doc (at begin)" do
      assert capture_io( :stderr, fn ->
        assert run!(@doc_at_beg) == ["<!-- begin @doc Main -->",
         "  This is Main",
         "  This is Main",
         "  This is Main",
         "<!-- end @doc Main -->",
         "after"]
      end) == ""
    end

    @doc_at_end ["before", "<!-- begin @doc Main -->", "<!-- end @doc Main -->"]
    test "only doc (at end)" do
      assert capture_io( :stderr, fn ->
        assert run!(@doc_at_end) == [ "before",
          "<!-- begin @doc Main -->",
          "  This is Main",
          "  This is Main",
          "  This is Main",
          "<!-- end @doc Main -->"]
      end) == ""
    end
  end

  describe "state machine, insert one doc, warnings" do
    @missing_end ["<!-- begin @doc Main -->"]
    test "edge case, missing end" do
      assert capture_io( :stderr, fn ->
        assert run!(@missing_end) == ["<!-- begin @doc Main -->",
         "  This is Main",
         "  This is Main",
         "  This is Main"]
      end) == "end @doc for Main (opened in line 1) missing\n"
    end

    @missing_end2 ["one", "<!-- begin @doc Main -->"]
    test "edge case, missing end 2nd line" do
      assert capture_io( :stderr, fn ->
        assert run!(@missing_end2) == ["one",
         "<!-- begin @doc Main -->",
         "  This is Main",
         "  This is Main",
         "  This is Main"]
      end) == "end @doc for Main (opened in line 2) missing\n"
    end
  end


  describe "state machine, complex example" do 
    
    @complex [ "<!-- begin @doc Main -->",
      "dissapears",
      "<!-- end @doc Main -->",
      "ramains",
      " <!-- begin @doc Main.Second -->",
      "",
      " <!-- end @doc Main.Second -->",
      "# <!-- end @doc Main -->",
      "<!-- begin @doc Main.Second.yes_doc --> ",
      "<!-- end @doc Main.Second.yes_doc --> ",
      "suffix"
    ]
    test "no warnings" do 
      assert capture_io( :stderr, fn ->
        assert run!(@complex) == [ "<!-- begin @doc Main -->",
          "  This is Main",
          "  This is Main",
          "  This is Main",
          "<!-- end @doc Main -->",
          "ramains",
          " <!-- begin @doc Main.Second -->",
          "  This is Main.Second",
          " <!-- end @doc Main.Second -->",
          "# <!-- end @doc Main -->",
          "<!-- begin @doc Main.Second.yes_doc --> ",
          "  This is yes_doc",
          "<!-- end @doc Main.Second.yes_doc --> ",
          "suffix"
        ]
      end) == ""
    end

    @illegal_end [ "<!-- begin @doc Main -->",
      "<!-- end @doc Main.alpha -->",
      "<!-- end @doc Main -->",
      "ramains",
      " <!-- begin @doc Main.Second -->",
      "",
      " <!-- end @doc Main.Second -->",
      "# <!-- end @doc Main -->",
      "<!-- begin @doc Main.Second.yes_doc --> ",
      "<!-- end @doc Main.Second.yes_doc --> ",
      "suffix"
    ]
    test "illegal end warnings" do 
      assert capture_io( :stderr, fn ->
        assert run!(@illegal_end) == [ "<!-- begin @doc Main -->",
          "  This is Main",
          "  This is Main",
          "  This is Main",
          "<!-- end @doc Main -->",
          "ramains",
          " <!-- begin @doc Main.Second -->",
          "  This is Main.Second",
          " <!-- end @doc Main.Second -->",
          "# <!-- end @doc Main -->",
          "<!-- begin @doc Main.Second.yes_doc --> ",
          "  This is yes_doc",
          "<!-- end @doc Main.Second.yes_doc --> ",
          "suffix"
        ]
      end) == "ignoring end @doc of Main.alpha (opened in line 5) as we are inside a @doc block for Main (opened in line 1)\n"
    end

    @many_warns [ "<!-- begin @doc Main -->",
      "<!-- begin @doc Main.alpha -->",
      "<!-- end @doc Main -->",
      "ramains",
      " <!-- begin @doc Main.Second -->",
      "",
      " <!-- end @doc Main.Second -->",
      "<!-- begin @doc DoesNotExist -->",
      "<!-- end @doc DoesNotExist -->",
      "# <!-- end @doc Main -->",
      "<!-- begin @doc Main.Second.yes_doc --> ",
      "<!-- end @doc Main.Second.yes_doc --> ",
      "suffix"
    ]
    test "many warnings" do 
      assert capture_io( :stderr, fn ->
        assert run!(@many_warns) == [ "<!-- begin @doc Main -->",
          "<!-- begin @doc Main.alpha -->",
          "  This is Main",
          "  This is Main",
          "  This is Main",
          "<!-- end @doc Main -->",
          "ramains",
          " <!-- begin @doc Main.Second -->",
          "  This is Main.Second",
          " <!-- end @doc Main.Second -->",
          "<!-- begin @doc DoesNotExist -->",
          "<!-- end @doc DoesNotExist -->",
          "# <!-- end @doc Main -->",
          "<!-- begin @doc Main.Second.yes_doc --> ",
          "  This is yes_doc",
          "<!-- end @doc Main.Second.yes_doc --> ",
          "suffix"
        ]
      end) == ["ignoring begin @doc of Main.alpha (opened in line 2) as we are inside a @doc block for Main (opened in line 1)\n",
       "No documentation found for DoesNotExist (opened in line 11)\n"] |> Enum.join("")
    end
  end
end
