class Game < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :player_games, :dependent => :destroy
  has_many :players, :through => :player_games

end
