class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
  	if(Playlist.find_by(location: "Dublin", genre: "Rock").blank?)
  		generate_playlist
  	else
  		render json: Playlist.find_by(location: "Dublin", genre: "Rock").songs
  	end
  end

  def generate_playlist
    Playlist.create(location: "Dublin", genre: "Rock")
    Song.create(name: "Luke Agnew's Song", artist_name: "Luke Agnew", url: "google.com", service: "Spotify")
    PlaylistsSong.create(playlist_id: 1, song_id: 1)

    render json: Playlist.find_by(location: "Dublin", genre: "Rock").songs
  end
end
