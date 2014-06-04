class PlayersController < ApplicationController
  around_filter :handle_record_not_found

  # TODO:  Make sure REST responses include URI
  #
  respond_to :json
  # GET /players.json
  def index
    if game
      @player_games = game.player_games
      respond_with @player_games, each_serializer: PlayerInGameSerializer, root: false
    else
      @players = Player.all
      respond_with @players, root: false
    end
  end

  # GET /players/1
  # GET /players/1.json
  def show
    if game
      @player_game = game.player_games.find_by_player_id(params[:id])
      respond_with @player_game, serializer: PlayerInGameSerializer, root: false
    else
      @player = Player.find(params[:id])
      respond_with @player
    end
  end

  # GET  /players/new.json
  def new
    @player = Player.new
    respond_with @player
  end

  # POST /players.json
  def create
    game # check that any supplied game_d is valid before creating the Player
    @player = Player.new(params[:player])

    if @player.save
      unless game.nil?
        game.players << @player
        game.save
      end
      respond_with @player, status: :created
    else
      respond_with @player.errors, status: :unprocessable_entity
    end
  end

  # PUT /players/1.json
  def update
    game # check that any supplied game_id is valid before updating the Player
    @player = Player.find(params[:id])

    if @player.update_attributes(params[:player])
      if game && !game.players.include?(@player)
        game.players << @player
        game.save
      end
      head :no_content
    else
      respond_with @player.errors, status: :unprocessable_entity
    end
  end

  # Adds an existing player to a game.
  # A valid game_id *must* be specified for this particular method.
  def add
    @player = Player.find(params[:id])
    if game
      unless game.players.include?(@player)
        game.players << @player
        game.save
      end
    else
      head :no_content, status: :unprocessable_entity
    end
  end

  # DELETE /players/1.json
  def destroy
    # idempotence demands that we ignore record-not-found errors
    if game
      @player_game = game.player_games.find_by_player_id(params[:id])
      if @player_game
        @player_game.destroy
      end
    else
      @player = Player.find_by_id(params[:id]) 
      if @player
        @player.destroy
      end
    end
    head :no_content 
  end

  protected
    # Retrieves the Game object if specified in params[:game_id]
    # Because it uses ActiveRecord#find, it will raise an exception if an
    # invalid game_id is specified.
    def game
      @game ||= (params.include?(:game_id) ? Game.find(params[:game_id]) : nil)
    end

    def handle_record_not_found
      yield
      rescue ActiveRecord::RecordNotFound => e
        respond_with({ errors: [ e.message ] },
                     { location: nil, status: :not_found })
    end
end
