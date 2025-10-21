defmodule App.CorrectionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Corrections` context.
  """

  @doc """
  Generate a correction.
  """
  def correction_fixture(attrs \\ %{}) do
    {:ok, correction} =
      attrs
      |> Enum.into(%{
        frame: 42,
        mouse_from: 42,
        mouse_to: 42
      })
      |> App.Corrections.create_correction()

    correction
  end
end
