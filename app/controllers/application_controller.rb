class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    if(((params[:location] != "0") && (params[:location].to_i ==0))  && ((params[:genre] != "0") && (params[:genre].to_i ==0)))
      location = params[:location]
      genre = params[:genre]
      if(Playlist.find_by(location: location, genre: genre).blank?)
         generate_playlist(location, genre)
      else
        render json: {:playlist => Playlist.find_by(location, genre), :songs => Playlist.find_by(location, genre).songs}
    
      end
    else 
      render json: "Location and genre must be a string value"
    end
  end

  def generate_playlist (location, genre)
    render text: location +" "+ genre
  end
end
