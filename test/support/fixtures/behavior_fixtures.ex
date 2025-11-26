defmodule App.BehaviorFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Behavior` context.
  """

  @doc """
  Generate a annotation.
  """
  def annotation_fixture(attrs \\ %{}) do
    {:ok, annotation} =
      attrs
      |> Enum.into(%{
        behavior: "some behavior",
        frame: 42,
        mouse_id: 42
      })
      |> App.Behavior.create_annotation()

    annotation
  end

  @doc """
  Generate a type_string.
  """
  def type_string_fixture(attrs \\ %{}) do
    {:ok, type_string} =
      attrs
      |> Enum.into(%{
        type_string: "some type_string"
      })
      |> App.Behavior.create_type_string()

    type_string
  end
end
