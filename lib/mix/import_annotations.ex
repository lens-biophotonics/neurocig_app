defmodule Mix.Tasks.ImportAnnotations do
  require Logger

  alias App.Videos

  def run(args) do
    Mix.Task.run("app.start")

    [path] = args

    import_annotations(path)
  end

  def import_annotations(path) do
    Path.wildcard(path <> "/*")
    |> Enum.map(&Path.basename/1)
    |> Enum.map(&import_video/1)
  end

  defp import_video(name) do
    IO.puts(name)

    case Videos.get_video_by_name(name) do
      nil ->
        {:ok, video} = Videos.create_video(%{name: name})
        video

      video ->
        video
    end
  end
end
