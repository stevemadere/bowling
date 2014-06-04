class Player < ActiveRecord::Base
  attr_accessible :name

  has_many :player_games
  has_many :games, :through => :player_game
end
