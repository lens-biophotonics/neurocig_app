defmodule App.VideosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Videos` context.
  """

  @doc """
  Generate a video.
  """
  def video_fixture(attrs \\ %{}) do
    {:ok, video} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> App.Videos.create_video()

    video
  end
end
