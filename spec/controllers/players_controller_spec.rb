
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
    Given!(:players_in_db) { Player.all.to_a }
    When(:response) { get(:index, format: :json) }
    Then { response.status.should eq(200) }
    And { (Set.new((JSON.parse response.body).map {|p| [p["id"],p["name"]]})).should eq(Set.new(players_in_db.map {|p| [p.id,p.name]})) }
  end



end
