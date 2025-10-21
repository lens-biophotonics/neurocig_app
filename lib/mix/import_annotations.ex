defmodule Mix.Tasks.ImportAnnotations do
  require Logger

  alias App.Videos

  def run(args) do
    Mix.Task.run("app.start")
    Logger.configure(level: :warn)

    [path] = args
    annotations = Path.wildcard(path <> "/*")

    import_video(hd(annotations))
  end

  defp import_video(name) do
    case Videos.get_video_by_name(name) do
      nil ->
        {:ok, video} = Videos.create_video(%{name: name})
        video

      video ->
        video
    end
  end
end
