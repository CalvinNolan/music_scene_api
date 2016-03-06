class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  require 'open-uri'
  require 'httparty'
  require 'soundcloud'


  def index
    if(((params[:location] != "0") && (params[:location].to_i ==0))  && ((params[:genre] != "0") && (params[:genre].to_i ==0)))
      location = params[:location]
      genre = params[:genre]
      if(Playlist.find_by(location: location, genre: genre).blank?)
         generatePlaylist(location, genre)
      else
        render json: {:playlist => Playlist.find_by(location, genre), :songs => Playlist.find_by(location, genre).songs}
      end
    else 
      render json: "Location and genre must be a string value"
    end
  end

  def generate_playlist (location, genre)
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

    @location=location
    @genre=genre


    @responseMusicBrainz = HTTParty.get('http://musicbrainz.org/ws/2/artist/?query=area:'+@location+'&fmt=json')
    @jsonMB = JSON.parse(@responseMusicBrainz.body)

    @arrayOfArtist=Array.new
    @arrayOfArtist=Array.new
    @arrayOfSources=Array.new
    @arrayOfSoundcloud=Array.new
    @arrayOfAlltheSources=Array.new
    @arrayOfUID=Array.new
    @arrayOfTracks=Array.new
    @user=Array.new
    @track=Array.new




    @jsonMB["artists"].each do |artist|
      @arrayOfArtist.append(artist["id"])
    end

    for id in @arrayOfArtist
      @responseOpenaura = HTTParty.get('http://api.openaura.com/v1/source/artists/'+id+'?id_type=musicbrainz%3Agid&api_key=')
      @arrayOfAlltheSources.append(JSON.parse(@responseOpenaura.body))
    end

    for sources in @arrayOfAlltheSources
      sources["sources"].each do |source|
         @arrayOfSources.append(source)
      end
    end

    for sources in @arrayOfSources
      #for source in sources
        if sources['oa_provider_id'] == 8
          @arrayOfUID.append(sources["uid"])
        end
      #end
    end

    # create a client object with your app credentials
    #client = Soundcloud.new(:client_id => '')
    #@artistSound=Array.new

    #@count=0;
    newP=Playlist.create(location: @location, genre: @genre)
    for uid in @arrayOfUID
      @responseSound=HTTParty.get('http://api.soundcloud.com/users/'+uid+'/tracks?client_id=&genres='+@genre)
      @tracks = JSON.parse(@responseSound.body)

=begin
      for track in @tracks
        if(@artist==track["user_id"])
          if(@count<1)
            @count++
            @arrayOfTracks.append(track)
          end
        else
          @count=1
        end


        @artist=track["user_id"]
=end
        @track=@tracks[0]
        @user=@track["user"]
        @username=@user["username"]
        @arrayOfTracks.append(@track)
        new_song = Song.create(name:@track["title"],artist_name:@username,url:@track["permalink_url"],service:"Soundcloud")
        PlaylistsSong.create(playlist_id: newP.id, song_id: new_song.id)
      #end
    end



    #render json: @arrayOfTracks
    #Playlist.find_by(location: @location, genre: @genre)
  end
end
