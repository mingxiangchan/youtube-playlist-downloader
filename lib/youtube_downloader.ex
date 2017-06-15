defmodule YoutubeDownloader do
  @default_download_path Path.expand("~/Downloads")
  @max_concurrent_downloads 5

  @moduledoc """
  Documentation for YoutubeDownloader.
  """

  def start do
    filepath = IO.gets "Please input the path to the playlist json\n"

    filepath
    |> decode_playlist_json
    |> download_items
    |> Stream.map(&YoutubeDownloader.extract_audio/1)
    |> Enum.to_list
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

  defp download_items(%{"items" => videos}) when is_list(videos) do
    Task.async_stream(
      videos,
      YoutubeDownloader,
      :queue_download,
      [],
      max_concurrency: @max_concurrent_downloads,
      timeout: :infinity
    )
  end

  def queue_download(video) do
    %{"snippet" => %{"title" => title}} = video
    %{"contentDetails" => %{"videoId" => video_id}} = video
    IO.puts "STARTING: Downloading video titled #{title}"
    try do
      "ytdl https://youtube.com/watch?v=#{video_id} > \"#{full_mp4_filepath(title)}\""
      |> String.to_charlist
      |> :os.cmd
      IO.puts "COMPLETED: Downloaded video to #{full_mp4_filepath(title)}"
      title
    rescue
      error ->
        IO.inspect error
        {:error, error}
    end
  end

  def extract_audio({:ok, title}) do
    IO.puts "STARTING: mp3 conversion for #{title}"
    "ffmpeg -i \"#{full_mp4_filepath(title)}\" \"#{full_mp3_filepath(title)}\" "
    |> String.to_charlist
    |> :os.cmd
    IO.puts "COMPLETED: mp3 conversion for #{title}"
  end

  defp full_mp4_filepath(title), do: "#{@default_download_path}/#{title}.mp4"
  defp full_mp3_filepath(title), do: "#{@default_download_path}/#{title}.mp3"
end
