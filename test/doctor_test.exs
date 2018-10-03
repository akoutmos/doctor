defmodule DoctorTest do
  use ExUnit.Case
  doctest Doctor

  test "greets the world" do
    assert Doctor.hello() == :world
  end
end
