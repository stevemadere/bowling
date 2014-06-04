class PlayerGame < ActiveRecord::Base
  attr_accessible :game_id, :player

  belongs_to :player
  belongs_to :game
  has_many :game_frames

  validates :player, presence: true

  def scores
    frame_list = game_frames.to_a
    result = {}
    frame_list.each do |frame| 
      result[frame.frame_number] = frame.nil? ? nil: frame.score
    end
    return result
  end

  # Current score is sum of the scores of the continuous sequence of
  # scoreable game_frames starting from frame 1
  def score
    frame_list = game_frames.to_a
    frames_indexed_by_frame_number = Array.new(10,nil)
    frame_list.each { |f| frames_indexed_by_frame_number[f.frame_number] = f }
    total_score = 0
    1.upto(10) do |frame_number|
      f = frames_indexed_by_frame_number[frame_number]
      break if f.nil? || (frame_score = f.score).nil?
      total_score += frame_score
    end
    return total_score
  end

  # Determines if enough rolls have been recorded to consider the game
  # finally scorable.
  def finished?
    frame_list = game_frames.to_a
    frame_list.size == 10 && frame_list.none? { |frame|  frame.score.nil? }
  end

  def final_score
    if finished?
      self.score
    else
      nil
    end
  end

  # Record a roll within a specific frame of the game
  def roll(frame_number, roll_number, pins_toppled)
    frame = game_frames.where(:frame_number => frame_number).first_or_create
    case roll_number
      when 1
        frame.roll1 = pins_toppled
      when 2
        frame.roll2 = pins_toppled
      when 3
        frame.roll3 = pins_toppled
    end
  end

end
