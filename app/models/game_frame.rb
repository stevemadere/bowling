
# Records the set of rolls in a frame of a Bowling Game and contains 
# the logic to calculate the score in a particular frame.  The score 
# of an entire game is the sum of the scores of the frames of the game.
#
# A set of pre-save validations enforce all of the rules of the game
class GameFrame < ActiveRecord::Base
  attr_accessible :frame_number, :player_game, :roll1, :roll2, :roll3

  belongs_to :player_game

  NUM_PINS = 10
  NUM_FRAMES = 10

  # cannot create a frame independent of a player_game
  validates :player_game, presence: true

  # The remaining validations prevent violations of the rules of the game
  validates :frame_number, inclusion: { in: (1..NUM_FRAMES) }

  validates :frame_number, uniqueness: { scope: :player_game_id,
              message: "frame_number must be unique within a player_game" }

  ALLOWABLE_ROLL_VALUES  = (0..NUM_PINS).to_a + [nil]
  [:roll1, :roll2, :roll3].each do |member|
    validates member, inclusion: { in: ALLOWABLE_ROLL_VALUES }
  end

  validates_each :roll2 do |frame, attr, value|
    if frame.strike? && !frame.terminal_frame? && !value.nil?
      frame.errors.add(attr,
        "non-terminal strike frames can only have one roll")
    end
    unless value.nil? || value + frame.roll1 <= NUM_PINS ||
            (frame.terminal_frame? && frame.strike?)
      frame.errors.add(attr,
        "Sum of rolls 1 and 2 cannot exceed #{NUM_PINS} unless striking on terminal frame") 
    end
  end

  validates_each :roll3 do |frame, attr, value|
    unless value.nil? || 
           (frame.terminal_frame? && (frame.strike? || frame.spare?))
      frame.errors.add(attr, "3 rolls only allowed in terminal frame with strike or spare") 
    end
  end

  def self.valid_frame_number?(fn)
    fn >=1 && fn <= NUM_FRAMES
  end

  # Calculates and returns the contribution of this frame to the overall 
  # PlayerGame score. 
  #
  # Returns nil if there is insufficient information to determine the 
  # score of the frame. e.g.: if a strike was thrown on this frame and
  # there have not yet been two successive rolls recorded.
  def score
    begin
      return (strike? || spare?) ? score_extended_frame : roll1 + roll2
    rescue TypeError => e1 # N + nil
      raise unless e1.message =~ /^nil can't be coerced/i
    rescue NoMethodError => e2 # nil + N
      raise unless e2.message =~ /for nil:NilClass$/i
    end
    # if any precursor is nil, return nil
    return nil
  end

  def strike?
    roll1 == NUM_PINS
  end

  def spare?
    roll1 + roll2 == NUM_PINS
  end

  def terminal_frame?
    frame_number == NUM_FRAMES
  end

  protected

    # used for calculating score of non-terminal spare or strike frames
    def next_frame
      return nil if terminal_frame?
      player_game.game_frames.where(:frame_number => frame_number + 1).first
    end

    # Calculate the score of a frame that has either a strike or spare
    def score_extended_frame
      raise "logic error" unless (strike? || spare?)
      if terminal_frame?
        # both strike and spare end up summing all three throws on the terminal
        return roll1 + roll2 + roll3
      else 
        # strike or spare on non-terminal frame so we need next_frame rolls
        nf = next_frame
        if strike?
          return roll1 + nf.roll1 + nf.second_roll_for_strike_score
        else # spare on current ordinary frame
          return NUM_PINS + nf.roll1
        end
      end
    end

    # Used only to calculate the score of a preceding strike frame
    # when another strike follows and this is not the terminal frame,
    # we must use roll1 of the following frame, otherwise just use 
    # the local roll2.
    def second_roll_for_strike_score
      ( self.strike? && !self.terminal_frame? ) ? next_frame.roll1 : self.roll2 
    end

end
