
require "spec_helper"
require "set"

describe PlayersController, :controllers do

  #Given(:user) { create :user }
  #before(:each) do
  #  sign_in user
  #end
  #
  Given!(:game) { Game.create }
  Given(:invalid_game_id) { Game.maximum(:id) + 1000 }

  describe "POST create" do
    Given(:player_attributes) { attributes_for(:player) }
    Given!(:previous_player_count) { Player.count }

    context "no game" do
      When(:response) { post(:create, {player: player_attributes, format: :json}) }
      Then { response.status.should eq(201) }
      And { Player.count.should == previous_player_count + 1 }
      And { JSON.parse(response.body)["name"].should eq(player_attributes[:name]) }
    end

    context "within game" do
      When(:response) { post(:create, {player: player_attributes, game_id: game.id, format: :json}) }
      Then { response.status.should eq(201) }
      And { Player.count.should == previous_player_count + 1 }
      And { JSON.parse(response.body)["name"].should eq(player_attributes[:name]) }
      And { game.players.size > 0 && game.players.any? { |p| p.name.should eq(player_attributes[:name])} } 
    end

    context "invalid game id" do
      When(:response) { post(:create, {player: player_attributes, game_id: invalid_game_id, format: :json}) }
      Then { response.status.should eq(404) }
      And { Player.count.should == previous_player_count }
    end

  end

  context "multi-player" do
    Given!(:created_players) { create_list(:player, 5) }
    Given!(:players_from_db) { Player.all.to_a }
    Given!(:players_in_game) { players_from_db.first(3) }
    Given { players_in_game.each { |p| game.players << p } ; game.save}
    describe "GET index" do
      context "no game" do
        When(:response) { get(:index, format: :json) }
        Then { response.status.should eq(200) }
        And { (Set.new(JSON.parse(response.body).map {|p| [p["id"],p["name"]]})).should eq(Set.new(players_from_db.map {|p| [p.id,p.name]})) }
      end

      context "within game" do
        When(:response) { get(:index, game_id: game.id, format: :json) }
        Then { response.status.should eq(200) }
        And { (Set.new(JSON.parse(response.body).map {|p| [p["id"],p["name"]]})).should eq(Set.new(players_in_game.map {|p| [p.id,p.name]})) }
        Then { JSON.parse(response.body).each { |p| p.should(have_key('current_score'))  && p.should(have_key('final_score')) } }
      end
      
      context "invalid game id" do
        When(:response) { get(:index, game_id: invalid_game_id, format: :json) }
        Then { response.status.should eq(404) }
      end

    end

    describe "GET show", :now do
      Given(:player_in_game) { players_in_game[2] }
      context "no game" do
        Given(:chosen_player) { player_in_game }
        When(:response) { get(:show, {id: chosen_player.id, format: :json}) }
        Then { response.status.should eq(200) }
        And { JSON.parse(response.body)["name"].should eq(chosen_player.name) }
        And { JSON.parse(response.body)["id"].should eq(chosen_player.id) }
      end
      context "within game" do
        Given(:chosen_player) { player_in_game }
        When(:response) { get(:show, {id: chosen_player.id, game_id: game.id, format: :json}) }
        Then { response.status.should eq(200) }
        And { JSON.parse(response.body)["name"].should eq(chosen_player.name) }
        And { JSON.parse(response.body)["id"].should eq(chosen_player.id) }
        And { JSON.parse(response.body).should have_key('current_score') }
      end
    end
  end

  describe "PUT update" do
    Given!(:created_players) { create_list(:player, 3) }
    Given(:players_from_db) { Player.all.to_a }
    Given(:original_player) { players_from_db[2] }
    Given(:orig_name) { original_player.name }
    Given(:new_name) { orig_name + "_modified" }
    When(:response) { put(:update, {id: original_player.id, player: {name: new_name} , format: :json}) }
    Then { response.status.should eq(204) }
    And { Player.find(original_player.id).name.should eq(new_name) }
  end

  describe "DELETE destroy" do
    Given!(:created_players) { create_list(:player, 3) }
    Given(:orig_players_from_db) { Player.all.to_a }
    Given(:dead_player_id) { orig_players_from_db[2].id }

    context "happy path" do
      When(:response) { delete(:destroy, {id: dead_player_id, format: :json}) }
      Then { response.status.should eq(204) }
      And { Player.find_by_id(dead_player_id).should be_nil }
      And { Player.all.to_a.should eq(orig_players_from_db.reject {|p| p.id == dead_player_id}) }
    end

    context "idempotence check" do
      Given { delete(:destroy, {id: dead_player_id, format: :json}) }
      Given!(:player_found_between_deletes) { Player.find_by_id(dead_player_id) }
      When(:response) { delete(:destroy, {id: dead_player_id, format: :json}) }
      Then { response.status.should eq(204) }
      And { player_found_between_deletes.should be_nil }
      And { Player.find_by_id(dead_player_id).should be_nil }
      And { Player.all.to_a.should eq(orig_players_from_db.reject {|p| p.id == dead_player_id}) }
    end

  end



end
