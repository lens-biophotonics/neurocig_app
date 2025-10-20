defmodule Mix.Tasks.ImportAnnotations do
  require Logger

  alias App.Videos
  alias App.Annotations
  alias App.Annotations.Annotation

  def run(args) do
    Mix.Task.run("app.start")
    Logger.configure(level: :warn)

    [path] = args
    annotations = Path.wildcard(path <> "/*")

    import_annotations(hd(annotations))

    # |> Enum.each(&import_annotation/1)
  end

  def import_annotations(path) do
    name = Path.basename(path) |> dbg()

    video =
      case Videos.get_video_by_name(name) do
        nil ->
          {:ok, video} = Videos.create_video(%{name: name})
          video

        video ->
          video
      end

    json =
      Path.join([path, name, "tracked_annotations.json"])
      |> load_json_from_file()

    Map.keys(json)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
    |> Tqdm.tqdm()
    |> Enum.each(&import_frame(&1, json, video))
  end

  def import_frame(frame, json, video) do
    frame_data = json[Integer.to_string(frame)]

    Map.keys(frame_data)
    |> Enum.sort()
    |> Enum.each(fn mouse_id ->
      {:ok, _ann} =
        %Annotation{
          video_id: video.id,
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
        |> Map.from_struct()
        |> Annotations.create_annotation()
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
