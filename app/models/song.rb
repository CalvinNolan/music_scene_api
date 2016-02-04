class Song < ActiveRecord::Base
	has_and_belongs_to_many :playlists

	validates :name, :artist_name, :url, presence: true
	validates :service, presence: true, format: { with: /\A(Spotify|Soundcloud)\z/,
    message: "Only Spotify and Soundcloud are supported for services" }
end
