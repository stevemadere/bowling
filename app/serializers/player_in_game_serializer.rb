
# Serializes a PlayerGame as if it were a Player object
# decorated with current_score and final_score
#
# Used by the PlayersController to retrieve a player
# with their scores
class PlayerInGameSerializer < ActiveModel::Serializer
  attributes :id, :name, :current_score, :final_score

  def id
    object.player.id
  end

  def name
    object.player.name
  end

  def current_score
    object.score
  end

end
