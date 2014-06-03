class PlayersController < ApplicationController

  # TODO:  Make sure REST responses include URI
  #
  respond_to :json
  # GET /players.json
  def index
    @players = Player.all
    respond_with @players
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @player = Player.find(params[:id])
    respond_with @player
  end

  # GET  /players/new.json
  def new
    @player = Player.new
    respond_with @player
  end

  # POST /players.json
  def create
    Rails.logger.error("in create")
    @player = Player.new(params[:player])
    Rails.logger.error("after new")
    if @player.save
      Rails.logger.error("after save")
      respond_with @player, status: :created
    else
      respond_with @player.errors, status: :unprocessable_entity
    end
  end

  # PUT /players/1.json
  def update
    @player = Player.find(params[:id])

    if @player.update_attributes(params[:player])
      head :no_content
    else
      respond_with @player.errors, status: :unprocessable_entity
    end
  end

  # DELETE /players/1.json
  def destroy
    # idempotence demands that we ignore record-not-found errors
    @player = Player.find_by_id(params[:id]) 
    if @player
      @player.destroy
    end
    head :no_content 
  end
end
