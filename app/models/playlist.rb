class Playlist < ActiveRecord::Base
	has_and_belongs_to_many :songs

	validates :location, :genre, presence: true
end
