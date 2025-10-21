defmodule App.Annotations do
  @moduledoc """
  The Annotations context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias App.Annotations.Annotation

  def load_annotations(video) do
    json =
      Path.join([
        Application.get_env(:app, :neurocig)[:annotations_path],
        video.name,
        "tracked_annotations.json"
      ])
      |> load_json_from_file()

    Map.keys(json)
    |> Enum.map(&String.to_integer/1)
    |> Map.new(&{&1, get_annotations_for_frame(&1, json, video)})
  end

  def get_annotations_for_frame(frame, json, video) do
    frame_data = json[Integer.to_string(frame)]

    Map.keys(frame_data)
    |> Map.new(fn mouse_id ->
      ann =
        %Annotation{
          video: video,
          frame: frame,
          mouse_id: String.to_integer(mouse_id),
          bb_x1: frame_data[mouse_id]["bbox"]["x1"],
          bb_y1: frame_data[mouse_id]["bbox"]["y1"],
          bb_x2: frame_data[mouse_id]["bbox"]["x2"],
          bb_y2: frame_data[mouse_id]["bbox"]["y2"],
          nose_x: (frame_data[mouse_id]["keypoints"]["nose"] || [nil, nil]) |> Enum.at(0),
          nose_y: (frame_data[mouse_id]["keypoints"]["nose"] || [nil, nil]) |> Enum.at(1),
          earL_x: (frame_data[mouse_id]["keypoints"]["earL"] || [nil, nil]) |> Enum.at(0),
          earL_y: (frame_data[mouse_id]["keypoints"]["earL"] || [nil, nil]) |> Enum.at(1),
          earR_x: (frame_data[mouse_id]["keypoints"]["earR"] || [nil, nil]) |> Enum.at(0),
          earR_y: (frame_data[mouse_id]["keypoints"]["earR"] || [nil, nil]) |> Enum.at(1),
          tailB_x: (frame_data[mouse_id]["keypoints"]["tailB"] || [nil, nil]) |> Enum.at(0),
          tailB_y: (frame_data[mouse_id]["keypoints"]["tailB"] || [nil, nil]) |> Enum.at(1)
        }

      {String.to_integer(mouse_id), ann}
    end)
  end

  def load_json_from_file(fname) do
    case File.read(fname) do
      {:ok, body} ->
        case JSON.decode(body) do
          {:ok, json} ->
            json

          {:error, _} ->
            Logger.error("Failed to decode JSON from #{fname}")
            %{}
        end

      {:error, _} ->
        Logger.error("Failed to read file #{fname}")
        %{}
    end
  end
end
