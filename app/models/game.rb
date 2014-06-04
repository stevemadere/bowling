class Game < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :player_games
  has_many :players, :through => :player_games

end
