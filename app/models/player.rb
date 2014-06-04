class Player < ActiveRecord::Base
  attr_accessible :name

  has_many :player_games, :dependent => :destroy
  has_many :games, :through => :player_game
end
