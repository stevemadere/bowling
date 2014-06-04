class CreateGameFrames < ActiveRecord::Migration
  def change
    create_table :game_frames do |t|
      t.references :player_game
      t.integer :frame_number
      t.integer :roll1, :default => nil
      t.integer :roll2, :default => nil
      t.integer :roll3, :default => nil

      t.timestamps
    end
  end
end
