
require "spec_helper"

describe GamesController, :controllers do

  #Given(:user) { create :user }
  #before(:each) do
  #  sign_in user
  #end
  #

  describe "POST create" do
    Given(:player_attributes) { attributes_for(:player) }
    Given!(:previous_game_count) { Game.count }

    When(:response) { post(:create , format: :json) }
      Then { response.status.should eq(201) }
      Then { Game.count.should == previous_game_count + 1 }
      And { JSON.parse(response.body).should have_key("id") }
    end

  describe "multi-game" do
    Given { 5.times { Game.create } }
    Given!(:existing_games) { Game.all.to_a }
    Given(:invalid_game_id) { Game.maximum(:id) + 1000}

    describe "GET index" do
      When(:response) { get(:index, format: :json) }
      Then { response.status.should eq(200) }
      And { (Set.new(JSON.parse(response.body).map {|g| g["id"]})).should eq(Set.new(existing_games.map {|g| g.id})) }
    end

    describe "GET show"  do
      Given(:existing_game) { existing_games[2] }
      context "valid game_id" do
        Given(:chosen_game) { existing_game }
        When(:response) { get(:show, {id: chosen_game.id, format: :json}) }
        Then { response.status.should eq(200) }
        And { JSON.parse(response.body)["id"].should eq(chosen_game.id) }
      end

      context "invalid game_id" do
        When(:response) { get(:show, {id: invalid_game_id, format: :json}) }
        Then { response.status.should eq(404) }
      end
    end

    describe "DELETE destroy" do
      Given(:dead_game_id) { existing_games[0].id }

      context "existing game" do
        When(:response) { delete(:destroy, {id: dead_game_id, format: :json}) }
        Then { response.status.should eq(204) }
        And { Game.find_by_id(dead_game_id).should be_nil }
      end

      context "idempotence check" do
        Given { delete(:destroy, {id: dead_game_id, format: :json}) }
        Given!(:game_found_between_deletes) { Game.find_by_id(dead_game_id) }
        When(:response) { delete(:destroy, {id: dead_game_id, format: :json}) }
        Then { response.status.should eq(204) }
        And { game_found_between_deletes.should be_nil }
        And { Game.find_by_id(dead_game_id).should be_nil }
        And { Game.all.to_a.should eq(existing_games.reject {|g| g.id == dead_game_id}) }
      end
    end

  end

end
