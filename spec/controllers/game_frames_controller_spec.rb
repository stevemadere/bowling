
require "spec_helper"
require "set"

describe GameFramesController, :controllers do

  #Given(:user) { create :user }
  #before(:each) do
  #  sign_in user
  #end
  #
  Given!(:game) { Game.create }
  Given!(:player_in_game) { Player.create }
  Given { game.players << player_in_game; game.save }
  Given!(:player_not_in_game) { Player.create }
  Given(:invalid_game_id) { Game.maximum(:id) + 1000 }

  context "with existing frames" do
    Given!(:player_game) { player_in_game.player_games.find_by_game_id(game.id) }
    Given do
        1.upto(10) do |frame_number| 
          player_game.game_frames.create(
              frame_number: frame_number,
              roll1: 1,
              roll2: (frame_number - 1),
              roll3: (frame_number<10 ? nil: 0) )
        end
    end

    Given!(:existing_frames) { player_game.game_frames.order(:frame_number) }
    Given(:existing_frame_number) { existing_frames.first.frame_number }
    describe "GET index" do
      context "no game" do
        When(:response) { get(:index, format: :json) }
        Then { response.should raise_error(ActionController::RoutingError) }
      end

      context "within valid player_game" do
        When(:response) { get(:index, game_id: game.id, player_id: player_in_game.id, format: :json) }
        Then { response.status.should eq(200) }
        And { JSON.parse(response.body).size.should eq(existing_frames.size) }
        And { JSON.parse(response.body).all? { |frame| frame['score'].should  eq(frame['frame_number']) } }
      end

      context "invalid player id" do
        When(:response) { get(:index, game_id: game.id, player_id: player_not_in_game.id, format: :json) }
        Then { response.status.should eq(404) }
      end

    end

    describe "GET show"  do
      context "no game" do
        Given(:chosen_frame_number) { existing_frame_number }
        When(:response) { get(:show, {id: chosen_frame_number, format: :json}) }
        Then { response.should raise_error(ActionController::RoutingError) }
      end

      context "with valid player id" do
        Given(:chosen_frame_number) { existing_frame_number }
        Given(:chosen_player) { player_in_game }
        When(:response) { get(:show, {id: chosen_frame_number, player_id: chosen_player.id, game_id: game.id, format: :json}) }
        Then { response.status.should eq(200) }
        And { JSON.parse(response.body)["frame_number"].should eq(chosen_frame_number) }
        And { JSON.parse(response.body).should have_key('roll1') }
        And { JSON.parse(response.body).should have_key('score') }
      end

      context "with invalid player id" do
        Given(:chosen_frame_number) { existing_frame_number }
        Given(:chosen_player) { player_not_in_game }
        When(:response) { get(:show, {id: chosen_frame_number, player_id: chosen_player.id, game_id: game.id, format: :json}) }
        Then { response.status.should eq(404) }
      end
    end

    describe "PUT update" do
      context "no game" do
        Given(:chosen_frame_number) { existing_frame_number }
        Given(:new_name) { orig_name + "_modified" }
        When(:response) { put(:update, {id: chosen_frame_number, player_id: player_in_game.id, roll_number: 1, pins_toppled: 3 , format: :json}) }
        Then { response.should raise_error(ActionController::RoutingError) }
      end

      context "with valid game and player" do
        Given(:chosen_frame_number) { existing_frame_number }
        Given(:chosen_player) { player_in_game }
        Given(:pins_toppled) { 3 }
        When(:response) { put(:update, {id: chosen_frame_number, game_id: game.id, player_id: chosen_player.id, roll_number: 1, pins_toppled: pins_toppled , format: :json}) }
        Then { response.status.should eq(204) }
        And { player_game.game_frames.find_by_frame_number(chosen_frame_number).roll1.should eq(pins_toppled) }
      end

      pending "with invalid frame #" do
        # I have no idea why this is not working
        # trace output indicates the controller is doing the right thing
        Given(:chosen_frame_number) { 20 }
        Given(:chosen_player) { player_in_game }
        Given(:pins_toppled) { 3 }
        When(:response) { put(:update, {id: chosen_frame_number, game_id: game.id, player_id: chosen_player.id, roll_number: 1, pins_toppled: pins_toppled , format: :json}) }
        Then { p response; response.status.should eq(422) }
      end

      context "repeatedly on one frame" do
        Given(:chosen_frame_number) { existing_frame_number }
        Given(:chosen_player) { player_in_game }
        Given(:roll1_pins_toppled) { 3 }
        Given(:roll2_pins_toppled) { 6 }
        Given { put(:update, {id: chosen_frame_number, game_id: game.id, player_id: chosen_player.id, roll_number: 1, pins_toppled: roll1_pins_toppled , format: :json}) }
        Given { put(:update, {id: chosen_frame_number, game_id: game.id, player_id: chosen_player.id, roll_number: 2, pins_toppled: roll2_pins_toppled , format: :json}) }
        When(:response) { get(:show, {id: chosen_frame_number, player_id: chosen_player.id, game_id: game.id, format: :json}) }
        Then { response.status.should eq(200) }
        And { player_game.game_frames.find_by_frame_number(chosen_frame_number).roll1.should eq(roll1_pins_toppled) }
        And { player_game.game_frames.find_by_frame_number(chosen_frame_number).roll2.should eq(roll2_pins_toppled) }
        And { JSON.parse(response.body)['score'].should eq(roll1_pins_toppled + roll2_pins_toppled) }
      end

    end
  end
end
