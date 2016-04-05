# Music Scene Playlist API

This is the repository for the API that supports the <a href="https://github.com/CalvinNolan/music_scene_web_app">Music Scene Web App</a>

This is an API that, given a location and a genre, will generate a playlist of songs from Soundcloud of music from that location and of that genre with the aim of giving a taste of the music scene in that location.

# Installation

This API is written with the Ruby on Rails Web Framework, follow <a href="https://gorails.com/setup/osx/10.11-el-capitan">this guide</a> to install the framework and any dependencies on OSX or Ubuntu before installing this API.

After installing Ruby on Rails run the ```bundle install``` command in the music_scene_api directory.

Next create and migrate the database by running ```rake db:create``` followed by ```rake db:migrate```.

In the project you will need to create a ```secrets.yml``` file in the ```music_scene_api/config/``` directory, the contents of the file should look something like this

```
development:
  secret_key_base: generated_key
  soundcloud_api_key: your_soundcloud_API_key

test:
  secret_key_base: generated_key

production:
  secret_key_base: generated_key
```

Run ```rake secret``` in the command line to generate your own secret key and replace ```generated_key``` with these keys.
You will need to get your own SoundCloud API to support your API from <a href="https://developers.soundcloud.com">here</a> and replace ```your_soundcloud_API_key``` with this key.

After you have finished this setup, run ```rails server``` in the music_scene_api directory to run the server, the API should now be hosted at ```localhost:3000``` while the server is running.

# API
The API supports two different requests, one for getting a playlist by passing a location and genre as a url parameter and a second for getting a playlist by it's id.

The first request is used to generate new playlists and can be sent through the root domain at ```http://localhost:3000?location=Dublin&genre=Rock```. You can expect a response like this 
```
{
 "playlist":{"id":7,"location":"Dublin","genre":"Techno","created_at":"2016-04-05T13:27:22.263Z","updated_at":"2016-04-05T13:27:22.263Z"},
 "songs":
 [
  {"id":102,"name":"Sunil Sharpe - Bodytonic 100 podcast segment","artist_name":"sunilsharpe","url":"https://api.soundcloud.com/tracks/11366962","service":"Soundcloud","created_at":"2016-04-05T13:27:23.381Z","updated_at":"2016-04-05T13:27:23.381Z",
    ...,
  {"id":103,"name":"LIVE @TECHNOIR 27.3.14","artist_name":"+ADEYHAWKE+","url":"https://api.soundcloud.com/tracks/141921677","service":"Soundcloud","created_at":"2016-04-05T13:27:24.407Z","updated_at":"2016-04-05T13:27:24.407Z"}
 ]
}
```

The second request is used to get an already generated playlist by it's id and is sent to ```http://localhost:3000/playlist/7``` where ```7``` is the playlist id number.  The response returned is identical to the one above. 

The first request can take up to 60 seconds to complete (depending on the amount of data to compute through), the second request is instantly returned.
