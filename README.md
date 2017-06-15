# YoutubeDownloader

1. Install mix deps

```
mix deps.get
```

2. Install cli tools to download and extracting audio

```
# https://github.com/fent/node-ytdl for video downloading
npm install ytdl -g

# ffmpeg for mp3 extracting
sudo apt install ffmpeg
```

3. Get json containing all items within the youtube playlist from https://developers.google.com/youtube/v3/docs/playlistItems/list

4. Run the script and input the path to the playlist JSON file!
```
mix download
```



