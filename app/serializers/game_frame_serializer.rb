
class GameFrameSerializer < ActiveModel::Serializer
  attributes :frame_number, :roll1, :roll2, :roll3, :score

end
