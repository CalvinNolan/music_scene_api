class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  require 'open-uri'
  require 'httparty'
  @json

  @arrayOfArtist
  def index
  		generate_playlist("Dublin","")
  end

  def generate_playlist(location,genre)
    $area=location



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

    @arrayOfArtist

  end
end
