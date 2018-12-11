defmodule CoffexTest do
  use ExUnit.Case
  doctest Coffex

  import Coffex.CLI, only: [parse_args: 1]

  test ":help returned" do
    assert parse_args(["-h", "any"]) == :help
    assert parse_args(["--help", "any"]) == :help
  end
end
