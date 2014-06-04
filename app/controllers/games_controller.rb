class GamesController < ApplicationController
  include RailsRemediation::ProperControllerResponses
  respond_to :json

  # GET /games.json
  def index
    @games = Game.all
    respond_with @games, root: false
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])
    respond_with @game
  end

  # GET  /games/new.json
  def new
    @game = Game.new
    respond_with @game
  end

  # POST /games.json
  def create
    @game = Game.new(params[:game])

    if @game.save
      respond_with @game, status: :created
    else
      respond_with @game.errors, status: :unprocessable_entity
    end
  end

  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])

    if @game.update_attributes(params[:game])
      head :no_content
    else
      respond_with @game.errors, status: :unprocessable_entity
    end
  end


  # DELETE /games/1.json
  def destroy
    # idempotence demands that we ignore record-not-found errors
    @game = Game.find_by_id(params[:id]) 
    if @game
      @game.destroy
    end
    head :no_content 
  end

end
