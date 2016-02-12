class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  require 'open-uri'
  require 'httparty'
  require 'soundcloud'
  @json
  @genre
  $area
  @arrayOfArtist
  def index
  		generate_playlist("Dublin","punk")
  end

  def generate_playlist(location,genre)
    $area=location
    @genre=genre


    @response = HTTParty.get('http://musicbrainz.org/ws/2/artist/?query=area:'+$area+'&fmt=json')
    @json = JSON.parse(@response.body)

    #@response = open('http://musicbrainz.org/ws/2/artist/?query=area:'+$area+'&fmt=json').read
    #printf @response
    #render json: @response
    filterArtistsNames(@json)
  end

  def filterArtistsNames(responseJson)


    @arrayOfArtist=Array.new

    @decode=responseJson

    @decode["artists"].each do |artist|
      @arrayOfArtist.append(artist["name"])
    end

    getTracksbyArtists(@arrayOfArtist)

  end


  def getTracksbyArtists(arrayOfArtist)



    # create a client object with your app credentials
    client = Soundcloud.new(:client_id => '2b06757c21ec3bf6797de8804c0788ba')
    @artistSound=Array.new

    @tracks = client.get('/tracks', :genres => @genre).each do |track|
      # now that we have the track id, we can get a list of comments, for example
      @user=client.get("/users/#{track.user.id}")
      @artistSound.append(@user.username)
    end

    compareArtists(arrayOfArtist,@artistSound)

    # find all tracks with the genre 'punk' that have a tempo greater than 120 bpm.
    #@tracks = client.get('/tracks/123')#:user => {:username => "Blink 182"})

    # a permalink to a track
    #track_url = 'http://soundcloud.com/forss/voca-nomen-tuum'

    # resolve track URL into track resource
    #track = client.get('/resolve', :url => track_url)

    #@comment=Array.new
    # now that we have the track id, we can get a list of comments, for example
    #client.get("/tracks/#{track.id}/comments").each do |comment|
    #   @comment.append("Someone said: #{comment.body} at #{comment.timestamp}")
    #end
  end
  def compareArtists(arrMusicBrainz,arrSound)

    @commun=Array.new
    arrMusicBrainz.each do |mb|
      arrSound.each do |sd|
        if(mb==sd)
          @commun.append(mb)
        end
      end
    end
  end
end
