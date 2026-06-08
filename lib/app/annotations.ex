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

    annotations =
      Map.keys(json)
      |> Enum.map(&String.to_integer/1)
      |> Map.new(&{&1, get_annotations_for_frame(&1, json, video)})

    charts = load_charts(video)

    Enum.reduce(charts, annotations, fn {frame, frame_map}, annotations ->
      frame = String.to_integer(frame)

      Enum.reduce(frame_map, annotations, fn {mouse_id, values}, annotations ->
        update_in(annotations, [frame, String.to_integer(mouse_id)], fn ann ->
          %{ann | charts: values}
        end)
      end)
    end)
  end

  def load_charts(video) do
    Path.join([
      Application.get_env(:app, :neurocig)[:charts_path],
      video.name <> "_charts.json"
    ])
    |> load_json_from_file()
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

  def reset_corrections(annotations) do
    Enum.reduce(Map.keys(annotations), annotations, fn frame, annotations ->
      Enum.reduce(Map.keys(annotations[frame]), annotations, fn mouse_id, annotations ->
        update_in(annotations[frame][mouse_id], fn ann -> %{ann | new_mouse_id: ann.mouse_id} end)
      end)
    end)
  end

  def apply_corrections_to_annotations(corrections, annotations) do
    annotations = reset_corrections(annotations)
    Enum.reduce(corrections, annotations, &apply_correction/2)
  end

  defp apply_correction(corr, annotations) do
    Enum.reduce(
      Map.keys(annotations) |> Enum.filter(&(&1 >= corr.frame)),
      annotations,
      fn frame, acc ->
        if Map.has_key?(acc, frame) and Map.has_key?(acc[frame], corr.mouse_from) and
             Map.has_key?(acc[frame], corr.mouse_to) do
          {_, found_from} =
            Enum.find(acc[frame], fn {_m_id, ann} -> ann.new_mouse_id == corr.mouse_from end)

          {_, found_to} =
            Enum.find(acc[frame], fn {_m_id, ann} -> ann.new_mouse_id == corr.mouse_to end)

          acc =
            update_in(acc[frame][found_from.mouse_id], fn ann ->
              %{ann | new_mouse_id: corr.mouse_to}
            end)

          acc =
            update_in(acc[frame][found_to.mouse_id], fn ann ->
              %{ann | new_mouse_id: corr.mouse_from}
            end)

          acc
        else
          acc
        end
      end
    )
  end
end
