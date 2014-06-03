class CreateRolls < ActiveRecord::Migration
  def change
    create_table :rolls do |t|
      t.integer :frame_id
      t.integer :roll_number

      t.timestamps
    end
  end
end
