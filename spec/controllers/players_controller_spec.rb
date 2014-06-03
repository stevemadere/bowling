
require "spec_helper"
require "set"

describe PlayersController, :controllers do

  #Given(:user) { create :user }
  #before(:each) do
  #  sign_in user
  #end
  #
  describe "POST create" do
    Given(:player_attributes) { attributes_for(:player) }
    Given!(:previous_player_count) { Player.count }
    When(:response) { post(:create, {player: player_attributes, format: :json}) }
    Then { response.status.should eq(201) }
    And { Player.count.should == previous_player_count + 1 }
    And { (JSON.parse response.body)["name"].should eq(player_attributes[:name]) }
  end

  describe "GET index" do
    Given!(:created_players) { create_list(:player, 3) }
    Given!(:players_from_db) { Player.all.to_a }
    When(:response) { get(:index, format: :json) }
    Then { response.status.should eq(200) }
    And { (Set.new((JSON.parse response.body).map {|p| [p["id"],p["name"]]})).should eq(Set.new(players_from_db.map {|p| [p.id,p.name]})) }
  end

  describe "GET show" do
    Given!(:created_players) { create_list(:player, 3) }
    Given!(:players_from_db) { Player.all.to_a }
    Given(:chosen_player) { players_from_db[2] }
    When(:response) { get(:show, {id: chosen_player.id, format: :json}) }
    Then { response.status.should eq(200) }
    And { (JSON.parse response.body)["name"].should eq(chosen_player.name) }
    And { (JSON.parse response.body)["id"].should eq(chosen_player.id) }
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
