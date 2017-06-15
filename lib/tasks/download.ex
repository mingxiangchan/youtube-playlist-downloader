defmodule Mix.Tasks.Download do
  use Mix.Task

  @desc "Runs the youtube downloader cli"
  def run(_) do
    YoutubeDownloader.start
  end
end

