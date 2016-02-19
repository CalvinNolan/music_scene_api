class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def index
    #test
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

  def get_playlist_by_id
    require 'uri'
    
    id_value = URI(request.original_url).path.split('/').last

    # Code to check that the last segment of the url passed
    # is of type int and to handle the case when it is not.



    if (id_value == "0" || id_value.to_i != 0)

      if (Playlist.find_by(id: id_value).blank?)
        render json: "Playlist not found, please enter another id."
      else
        render json: {:playlist => Playlist.find_by(id: id_value), :songs => Playlist.find_by(id: id_value).songs}
      end

    else
      render json: "Invalid request, id must be an Integer. Received " + id_value
    end
  end
end
