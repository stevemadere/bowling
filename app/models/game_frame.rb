
# Records the set of rolls in a frame of a Bowling Game and contains 
# the logic to calculate the score in a particular frame.  The score 
# of an entire game is the sum of the scores of the frames of the game.
#
class GameFrame < ActiveRecord::Base
  attr_accessible :frame_number, :player_game, :roll1, :roll2, :roll3

  belongs_to :player_game

  # cannot create a frame without associating ith with a player_game
  validates :player_game, presence: true

  validates :frame_number, inclusion: { in: (1..10) }

  validates :frame_number, uniqueness: { scope: :player_game_id,
              message: "frame_number must be unique with a player_game" }

  ALLOWABLE_ROLL_VALUES  = (0..10).to_a + [nil]
  [:roll1, :roll2, :roll3].each do |member|
    validates member, inclusion: { in: ALLOWABLE_ROLL_VALUES }
  end

  validates_each :roll2 do |frame, attr, value|
    if frame.strike? && frame.frame_number != 10 && !value.nil?
      frame.errors.add(attr,
        "non-terminal strike frames can only have one roll")
    end
    unless value.nil? || (frame.frame_number == 10 && frame.strike?) ||
           value + frame.roll1 <= 10
      frame.errors.add(attr,
        "Sum of rolls 1 and 2 cannot exceed 10 unless striking on final frame") 
    end
  end

  validates_each :roll3 do |frame, attr, value|
    unless value.nil? || 
           (frame.frame_number == 10 && (frame.strike? || frame.spare?))
      frame.errors.add(attr, "3 rolls only allowed on strike or spare 10th frame") 
    end
  end


  # Calculates and returns the contribution of this frame to the overall 
  # PlayerGame score.  Returns nil if there is insufficient
  # information to determine the score of the frame. e.g.: if a strike was
  # thrown on this frame and there have not yet been two successive rolls
  # recorded.
  def score
    begin
      # First, handle the simple case were we have neither a strike nor a spare
      # this weirdly redundant check is to avoid adding roll2==nil to roll1==10
      # and thus triggering  a TypeError exception
      if roll1 < 10 && roll1 + roll2 < 10
         return roll1 + roll2
      end
      # We have a strike or spare so special cases ensue
      if frame_number == 10
        # both strike and spare end up summing all three throws on 10th frame
        return roll1 + roll2 + roll3
      else # strike or spare on ordinary frame 
        nf = next_frame
        if roll1 == 10 # strike on current ordinary frame
          return roll1 + nf.roll1 + nf.second_roll
        else # spare on current ordinary frame
          return 10 + nf.roll1
        end
      end
    rescue TypeError # if required rolls are not yet set, score is indeterminate
      return nil
    end
  end

  def strike?
    roll1 == 10
  end

  def spare?
    roll1 + roll2 == 10
  end

  protected
    def next_frame
      return nil if frame_number == 10
      player_game.game_frames.where(:frame_number => frame_number + 1).first
    end

    def second_roll
      ( self.strike? && self.frame_number != 10 ) ? next_frame.roll1 : self.roll2 
    end

end
