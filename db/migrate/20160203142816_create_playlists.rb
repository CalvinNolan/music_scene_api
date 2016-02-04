class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :location
      t.string :genre

      t.timestamps null: false
    end
  end
end
