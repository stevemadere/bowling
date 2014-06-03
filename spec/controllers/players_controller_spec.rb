
require "spec_helper"

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
end
