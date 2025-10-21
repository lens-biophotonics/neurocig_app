defmodule App.AnnotationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Annotations` context.
  """

  @doc """
  Generate a annotation.
  """
  def annotation_fixture(attrs \\ %{}) do
    {:ok, annotation} =
      attrs
      |> Enum.into(%{
        frame_id: 42
      })
      |> App.Annotations.create_annotation()

    annotation
  end
end
