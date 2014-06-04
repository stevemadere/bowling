
require "spec_helper"
require "set"

describe GameFrame, :integration do

  #Given(:user) { create :user }
  #before(:each) do
  #  sign_in user
  #end
  #
  Given(:player) { create(:player) }
  Given(:player_game) { PlayerGame.create(player: player) }

  describe "create" do
    (1..10).each do |valid_frame_number|
      context "valid parameters" do
        When(:created_frame) { GameFrame.create!(player_game: player_game, frame_number: valid_frame_number) }
        Then { created_frame.player_game.should eq(player_game) }
        And { created_frame.frame_number.should eq(valid_frame_number) }
      end
    end

    [-1, 11].each do |invalid_frame_number|
      context "invalid parameters" do
        When(:created_frame) { GameFrame.create!(player_game: player_game, frame_number: invalid_frame_number) }
        Then { created_frame.should raise_error }
      end
    end
  end

  (1..10).each do |frame_number|
    context "frame first roll validation" do
      Given(:frame) { GameFrame.create(player_game: player_game, frame_number: frame_number) }

      # confirm than anything in 1 to 10 is valid for a first roll
      (1..10).each do |num_pins|
        context "allowable first roll" do
          Given { frame.roll1 = num_pins }
          When(:validity) { frame.valid? }
          Then { validity.should be_true }
        end
      end

      # confirm that values just outside of 1..10 yield invalid first roll
      [-1, 11].each do |num_pins|
        context "invalid first roll" do
          Given { frame.roll1 = num_pins }
          When(:validity) { frame.valid? }
          Then { validity.should be_false }
        end
      end
    end
  end

  (1..9).each do |frame_number|
    context "non-terminal frame second roll validation" do
      Given(:frame) { GameFrame.create(player_game: player_game, frame_number: frame_number) }
      # Check all combinations of first and second rolls
      (1..9).each do |first_pins|

        # first, all valid combinations
        10.downto(first_pins) do |frame_score|
          context "valid rolls: #{first_pins}, #{frame_score - first_pins}" do
            Given {frame.roll1 = first_pins }
            Given {frame.roll2 = frame_score - first_pins }
            When(:validity) { frame.valid? }
            Then { validity.should be_true }
          end
        end

        # Then the boundary-case invalid combinations
        [11,first_pins-1].each do |frame_score|
          context "invalid rolls: #{first_pins}, #{frame_score - first_pins}" do
            Given {frame.roll1 = first_pins }
            Given {frame.roll2 = frame_score - first_pins }
            When(:validity) { frame.valid? }
            Then { validity.should be_false }
          end
        end
      end

      # confirm that any second roll after a strike is invalid
      context "after strike" do
        Given { frame.roll1 = 10 }
        (-1..11).each do |second_pins|
          context "invalid second roll of #{second_pins}" do
            Given { frame.roll2 = second_pins }
            When(:validity) { frame.valid? }
            Then { validity.should be_false }
          end
        end
      end

    end
  end

  context "terminal frame second roll validation", :now do
    Given(:terminal_frame) { GameFrame.create(player_game: player_game, frame_number: 10) }

      # confirm that any second and third roll <=10 after a strike is valid
      context "after strike" do
        Given { terminal_frame.roll1 = 10 }
        (0..10).each do |second_pins|
          (0..10).each do |third_pins|
            context "valid second and third rolls of #{second_pins}, #{third_pins}" do
              Given { terminal_frame.roll2 = second_pins }
              Given { terminal_frame.roll3 = third_pins }
              When(:validity) { terminal_frame.valid? }
              Then { validity.should be_true }
              And { terminal_frame.score.should eq(10+ second_pins + third_pins)}
            end
          end
        end

        # roll values that are always invalid should be so or a terminal frame too
        [-1,11].each do |second_pins|
          context "invalid second roll of #{second_pins}" do
            Given { terminal_frame.roll2 = second_pins }
            When(:validity) { terminal_frame.valid? }
            Then { validity.should be_false }
          end
        end
      end
  end

end

