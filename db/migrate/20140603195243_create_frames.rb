class CreateFrames < ActiveRecord::Migration
  def change
    create_table :frames do |t|
      t.integer :player_game_id
      t.integer :frame_number

      t.timestamps
    end
  end
end
