defmodule App.Annotations do
  @moduledoc """
  The Annotations context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Videos.Video
  alias App.Annotations.Annotation

  @doc """
  Returns the list of annotations.

  ## Examples

      iex> list_annotations()
      [%Annotation{}, ...]

  """
  def list_annotations do
    Repo.all(Annotation)
  end

  @doc """
  Gets a single annotation.

  Raises `Ecto.NoResultsError` if the Annotation does not exist.

  ## Examples

      iex> get_annotation!(123)
      %Annotation{}

      iex> get_annotation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_annotation!(id), do: Repo.get!(Annotation, id)

  @doc """
  Creates a annotation.

  ## Examples

      iex> create_annotation(%{field: value})
      {:ok, %Annotation{}}

      iex> create_annotation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_annotation(attrs) do
    %Annotation{}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a annotation.

  ## Examples

      iex> update_annotation(annotation, %{field: new_value})
      {:ok, %Annotation{}}

      iex> update_annotation(annotation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_annotation(%Annotation{} = annotation, attrs) do
    annotation
    |> Annotation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a annotation.

  ## Examples

      iex> delete_annotation(annotation)
      {:ok, %Annotation{}}

      iex> delete_annotation(annotation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_annotation(%Annotation{} = annotation) do
    Repo.delete(annotation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking annotation changes.

  ## Examples

      iex> change_annotation(annotation)
      %Ecto.Changeset{data: %Annotation{}}

  """
  def change_annotation(%Annotation{} = annotation, attrs \\ %{}) do
    Annotation.changeset(annotation, attrs)
  end

  def get_annotations(%Video{} = video, frame) do
    from(a in Annotation, where: a.video_id == ^video.id and a.frame == ^frame)
    |> Repo.all()
  end

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
    |> Enum.sort()
    |> Map.new(&{&1, get_annotations_for_frame(&1, json, video)})
  end

  def get_annotations_for_frame(frame, json, video) do
    frame_data = json[Integer.to_string(frame)]

    Map.keys(frame_data)
    |> Enum.sort()
    |> Map.new(fn mouse_id ->
      ann =
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
