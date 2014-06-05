class GameFramesController < ApplicationController
  include RailsRemediation::ProperControllerResponses
  # TODO:  Make sure REST responses include URI
  #
  respond_to :json

  # GET /games/GAME_ID/players/PLAYER_ID/game_frames.json
  def index
    @game_frames = player_game.game_frames.to_a
    respond_with @game_frames, each_serializer: GameFrameSerializer, root: false
  end

  # GET /games/GAME_ID/players/PLAYER_ID/game_frames/1.json
  def show
    @game_frame = player_game.game_frames.find_by_frame_number(frame_number)
    if !@game_frame
      @game_frame = GameFrame.new(frame_number: frame_number)
    end

    respond_with @game_frame, serializer: GameFrameSerializer, root: false
  end

  # PUT /games/GAME_ID/players/PLAYER_ID/game_frames/1.json
  def update
    roll_member = "roll#{params[:roll_number]}".to_sym
    update_params = HashWithIndifferentAccess.new
    update_params[:frame_number] = frame_number
    update_params[roll_member] = params[:pins_toppled].to_i
    @game_frame = player_game.game_frames.find_by_frame_number(frame_number)
    success = false
    errors = nil
    if !@game_frame
      Rails.logger.error("creating GameFrame with #{update_params.to_json}")
      @game_frame = player_game.game_frames.create!(update_params)
      success = !@game_frame.nil?
      errors = "failed to create GameFRAME"
    else
      Rails.logger.error("updating GameFrame #{@game_frame.to_json} with #{update_params.to_json}")
      success = @game_frame.update_attributes(update_params)
      @game_frame.save
      errors = @game_frame.errors
    end
    if success
      head :no_content
    else
      respond_with errors, status: :unprocessable_entity
    end
  end

  protected
    # Retrieves the Game object if specified in params[:game_id]
    # Because it uses ActiveRecord#find, it will raise an exception if an
    # invalid game_id is specified.
    def game
      @game ||= Game.find(params[:game_id])
    end

    def player_game
      @player_game ||= game.player_games.find_by_player_id(params[:player_id])
      raise ActiveRecord::RecordNotFound, "Player with id #{params[:player_id]} not not part of game #{game.id}" unless @player_game 
      return @player_game
    end

    def frame_number
      return @frame_number if @frame_number
      specified_frame_number = params[:id].to_i
      raise InvalidParameter "Frame number #{specified_frame_number} is invalid" unless GameFrame.valid_frame_number?(specified_frame_number)
      @frame_number = specified_frame_number
    end

end
