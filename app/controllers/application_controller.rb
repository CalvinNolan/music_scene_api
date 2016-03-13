class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  require 'open-uri'
  require 'httparty'
  require 'soundcloud'


  def index
    if !(params.has_key?(:location) && params.has_key?(:genre))
      render json: "You must pass location and genre as url parameters"
    elsif ((params[:location] != "0") && (params[:location].to_i == 0)) && ((params[:genre] != "0") && (params[:genre].to_i == 0))
      location = params[:location]
      genre = params[:genre]
      if(Playlist.find_by(location: location, genre: genre).blank?)
         generatePlaylist(location, genre)
      else
        render json: {:playlist => Playlist.find_by(location: location, genre: genre), :songs => Playlist.find_by(location: location, genre: genre).songs}
      end
    else 
      render json: "Location and genre must be a string value"
    end
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


  def generatePlaylist(location,genre)
    puts "Generating playlists for Location: " + location.to_s + " & Genre: " + genre.to_s

    # Get all the artists in a given location from MusicBrainz.
    @responseMusicBrainz = HTTParty.get('http://musicbrainz.org/ws/2/artist/?query=area:' + location + '&fmt=json')
    @jsonMB = JSON.parse(@responseMusicBrainz.body)
    
    # Resend the request until there is a non-error response.
    while @jsonMB['error']
      @responseMusicBrainz = HTTParty.get('http://musicbrainz.org/ws/2/artist/?query=area:' + location + '&fmt=json')
      @jsonMB = JSON.parse(@responseMusicBrainz.body)
    end

    puts "1/3 List of artists in location attained."

    @artistsInfo = Array.new

    # Create an array of all the artist's SoundCloud info that were found through MusicBrainz.
    @jsonMB["artists"].each do |artist|
      @artistRelations = HTTParty.get('http://musicbrainz.org/ws/2/artist/' + artist["id"] + '?inc=url-rels&fmt=json')
      @jsonRelations = JSON.parse(@artistRelations.body)

      # Resend the request until there is a non-error response.
      while @jsonRelations['error']
        sleep 1
        @artistRelations = HTTParty.get('http://musicbrainz.org/ws/2/artist/' + artist["id"] + '?inc=url-rels&fmt=json')
        @jsonRelations = JSON.parse(@artistRelations.body)
      end

      @jsonRelations['relations'].each do |relation|
        if relation['type'] == 'soundcloud'
          @soundcloudArtistInfo = HTTParty.get('http://api.soundcloud.com/resolve?url=' + relation['url']['resource'] + '&client_id=' + Rails.application.secrets.soundcloud_api_key)
          if !@soundcloudArtistInfo.body.blank?
            @artistsInfo.append(JSON.parse(@soundcloudArtistInfo.body))
          end
          break
        end
      end
    end

    puts "2/3 Artists SoundCloud information attained."

    newP=Playlist.create(location: location, genre: genre)
    for artist in @artistsInfo
      if !artist["errors"]
        @responseSound=HTTParty.get('http://api.soundcloud.com/users/' + artist["id"].to_s + '/tracks?client_id=' + Rails.application.secrets.soundcloud_api_key)
        @tracks = JSON.parse(@responseSound.body)

        for track in @tracks
          if track["genre"].downcase.include? genre.downcase
            new_song = Song.create(name:track["title"],artist_name:track["user"]["username"],url:track["uri"],service:"Soundcloud")
            PlaylistsSong.create(playlist_id: newP.id, song_id: new_song.id)
          end
        end
      end
    end

    puts "3/3 Playlist created and populated"

    render json: {:playlist => Playlist.find_by(location: location, genre: genre), :songs => Playlist.find_by(location: location, genre: genre).songs}
  end
end
