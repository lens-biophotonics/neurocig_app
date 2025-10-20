defmodule Mix.Tasks.ImportVideos do
  require Logger

  alias App.Videos

  def run(args) do
    [path] = args
    Mix.Task.run("app.start")

    {:ok, flist} = File.ls(path)

    Enum.sort(flist)
    |> Enum.each(fn video -> Videos.create_video(%{name: video}) end)
  end
end
