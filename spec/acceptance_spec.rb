
require 'spec_helper'
require 'rest-client'
require 'set'

def base_url
  'http://localhost:3000'
end

def rest_post(path,params = {})
  full_url = (path =~ /^https?:\/\//) ? path : "#{base_url}/#{path}"
  response = ::RestClient.post(full_url,params.to_json,
                              { content_type: :json,
                                accept: :json})
  JSON.parse(response.body) rescue response.body
end

def build_url(path,params)
  url_params_list = []
  params.each { |k,v| url_params_list << "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }
  url_params = url_params_list.join('&')
  full_url = (path =~ /^https?:\/\//) ? path : "#{base_url}/#{path}"
  full_url += ("?#{url_params}") if url_params.length > 0
  #puts "getting #{full_url}"
  full_url
end

def rest_get(path,params = {})

  response = ::RestClient.get(build_url(path,params),
                              { content_type: :json,
                                accept: :json})
  #puts "response body is #{response.body}"
  JSON.parse(response.body) rescue response.body
end

def rest_put(path,params = {})

  response = ::RestClient.put(build_url(path,params),
                              { content_type: :json,
                                accept: :json})
  #puts "response body is #{response.body}"
  JSON.parse(response.body) rescue response.body
end
                                
def rest_delete(path,params = {})

  response = ::RestClient.delete(build_url(path,params),
                              { content_type: :json,
                                accept: :json})
  #puts "response body is #{response.body}"
  JSON.parse(response.body) rescue response.body
end
                                

describe "acceptance test", :acceptance do
  describe "list players" do
    Given(:game) { rest_post("/games")}
    Given!(:player1) { rest_post("/games/#{game['id']}/players", {name: 'player1'}) }
    Given!(:player2) { rest_post("/games/#{game['id']}/players", {name: 'player2'})}
    When(:player_list) { rest_get("/games/#{game['id']}/players.json") }
    Then { Set.new(player_list.map { |p| p['id'] }).should eq(Set.new([ player1['id'], player2['id'] ] )) } 
    
  end

  describe "full game" do
    Given(:game) { rest_post("/games")}
    Given!(:player1) { rest_post("/games/#{game['id']}/players", {name: 'player1'}) }
    Given!(:player2) { rest_post("/games/#{game['id']}/players", {name: 'player2'})}
    Given do
      1.upto(10) do |frame_number|
        rest_put("/games/#{game['id']}/players/#{player1['id']}/game_frames/#{frame_number}", {roll_number: 1, pins_toppled: 10})
        rest_put("/games/#{game['id']}/players/#{player2['id']}/game_frames/#{frame_number}", {roll_number: 1, pins_toppled: 1})
        rest_put("/games/#{game['id']}/players/#{player2['id']}/game_frames/#{frame_number}", {roll_number: 2, pins_toppled: 2})
      end
      frame_number = 10
      rest_put("/games/#{game['id']}/players/#{player1['id']}/game_frames/#{frame_number}", {roll_number: 2, pins_toppled: 10})
      rest_put("/games/#{game['id']}/players/#{player1['id']}/game_frames/#{frame_number}", {roll_number: 3, pins_toppled: 10})
    end

    When(:player_list) { rest_get("/games/#{game['id']}/players.json") }

    Then { Set.new(player_list.map { |p| [ p['id'], p['current_score']] }).should eq(Set.new([ [ player1['id'], 300 ] ,  [ player2['id'], 30 ] ] )) }
    And { player_list.all? { |p| p['final_score'].should_not be_nil } } 
    
  end
end
