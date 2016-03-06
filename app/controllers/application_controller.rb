class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def index
    if(((params[:location] != "0") && (params[:location].to_i == 0))  && ((params[:genre] != "0") && (params[:genre].to_i == 0)))
      location = params[:location]
      genre = params[:genre]
      if(Playlist.find_by(location: location, genre: genre).blank?)
         generate_playlist(location, genre)
      else
        render json: {:playlist => Playlist.find_by(location: location, genre: genre), 
            :songs => Playlist.find_by(location: location, genre: genre).songs}
      end
    else 
      render json: "Location and genre must be a string value"
    end
  end

  def generate_playlist (location, genre)
    render json: {location: location,  genre: genre}
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
