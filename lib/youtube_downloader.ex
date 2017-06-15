defmodule YoutubeDownloader do
  @default_download_path Path.expand("~/Downloads")
  @task_stream_options [
    max_concurrency: 3,
    timeout: :infinity
  ]

  @moduledoc """
  Documentation for YoutubeDownloader.
  """

  def start do
    #filepath = IO.gets "Please input the path to the playlist json\n"

    #filepath

    "~/Downloads/playlist.json"
    |> decode_playlist_json
    |> Map.get("items")
    |> Task.async_stream(&YoutubeDownloader.download/1, @task_stream_options)
    |> Enum.map(&YoutubeDownloader.extract_audio/1)
  end

  defp decode_playlist_json(filepath) do
    filepath
    |> String.strip
    |> Path.expand
    |> File.read
    |> case do
      {:ok, file_contents} ->
        case Poison.decode(file_contents) do
          {:ok, json} -> json
          {:error, _error} -> raise "Error parsing file contents to json"
        end
      {:error, _error} -> raise "Error reading file at path #{filepath}"
    end
  end

  def download(video) do
    %{"snippet" => %{"title" => title}} = video
    %{"contentDetails" => %{"videoId" => video_id}} = video
    IO.puts "STARTING: Downloading video titled #{title}"
    try do
      "ytdl https://youtube.com/watch?v=#{video_id} > \"#{full_mp4_filepath(title)}\""
      |> String.to_charlist
      |> :os.cmd
      title
    rescue
      error ->
        IO.inspect error
        {:error, error}
    end
  end

  def extract_audio({:ok, title}) do
    "ffmpeg -i \"#{full_mp4_filepath(title)}\" \"#{full_mp3_filepath(title)}\" "
    |> String.to_charlist
    |> :os.cmd
    IO.puts "COMPLETED: mp3 conversion for #{title}"
  end

  defp full_mp4_filepath(title), do: "#{@default_download_path}/#{title}.mp4"
  defp full_mp3_filepath(title), do: "#{@default_download_path}/#{title}.mp3"
end
