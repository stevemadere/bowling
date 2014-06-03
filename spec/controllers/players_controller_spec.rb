
require "spec_helper"

describe PlayersController, :controllers do

  #Given(:user) { create :user }
  #before(:each) do
  #  sign_in user
  #end
  #
  describe "POST create" do
    Given(:player_attributes) { attributes_for(:player) } # FIXME check syntax
    Given!(:previous_player_count) { Player.count }
    When(:created_player) { post(:create, player_attributes, format: json) }
    Then { Player.count.should == previous_player_count + 1 }
    And { puts created_player.to_json }
  end
end
