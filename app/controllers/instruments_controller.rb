class InstrumentsController < ApplicationController
  
  before_filter :rewrite_api_parameters, :only => [:create, :update]
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :ensure_owned, :except => [:index, :show, :list]
  before_filter :breadcrumb
  
  def breadcrumb
    return if request.format == 'application/json'
    if is_owned?
      add_breadcrumb  I18n.t('breadcrumbs.own_instruments'), Proc.new { |c| c.user_instruments_path(c.current_user) }
    elsif @user_id
      add_breadcrumb  I18n.t('breadcrumbs.other_instruments', :user => User.find(@user_id).screen_name), Proc.new { |c| c.user_instruments_path(@user_id) }
    end
  end
  
  # GET /users/1/instruments
  def index
    if is_owned?
      @instruments = current_user.instruments
    else
      @instruments = User.find(@user_id).instruments
    end
    
    
    respond_to do |format|
      format.html
      format.json { render :json =>@instruments.to_json(:include => :location) }
    end
  end

  # GET /users/1/instruments/1
  def show
    @instrument = Instrument.find(params[:id])
    respond_to do |format|
      format.html { add_breadcrumb @instrument.model, :user_instrument_path }
      format.json { render :json =>@instrument.to_json(:include => :location) }
    end
  end

  # GET /users/1/instruments/new
  def new
    @data_types = DataType.all
    @instrument = Instrument.new
    @instrument.location = Location.new
    @locations = current_user.locations
    add_breadcrumb I18n.t('new'), :new_user_instrument_path
  end

  # GET /users/1/instruments/1/edit
  def edit
    @data_types = DataType.all
    @instrument = Instrument.find(params[:id])
    @instrument.location ||= Location.new
    add_breadcrumb @instrument.model, :user_instrument_path
    add_breadcrumb I18n.t('edit'), :edit_user_instrument_path
  end

  # POST /users/1/instruments
  def create
    @instrument = Instrument.create(params[:instrument])
    current_user.instruments << @instrument
    if @instrument.valid?
      respond_to do |format|
        format.html { redirect_to [current_user, @instrument], :notice => t('instruments.create.successful') }
        format.json { render :json =>@instrument.to_json(:include => :location) }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :json => @instrument.errors, :status => 406}
      end
    end
  end

  # PUT /users/1/instruments/1
  def update
    @instrument = Instrument.find params[:id]
    if @instrument.user == current_user
      if @instrument.update_attributes params[:instrument]
        respond_to do |format|
          format.html { redirect_to [current_user, @instrument], :notice => t('.success_message') }
          format.json { render :json =>@instrument.to_json(:include => :location) }
        end
      else
        respond_to do |format|
          format.html { render :action => "edit" }
          format.json { render :json => @instrument.errors, :status => 406}
        end
      end
    else
      respond_to do |format|
        format.html { render :action => "show" }
        format.json { render :json => @instrument, :status => 401}
      end
    end
  end

  # DELETE /users/1/instruments/1
  def destroy
    @instrument = current_user.instruments.where(:id => params[:id]).first
    if @instrument
      @instrument.destroy
      respond_to do |format|
        format.html { redirect_to(user_instruments_url) }
        format.json { render :json =>@instrument.to_json(:include => :location)}
      end
    else
      respond_to do |format|
        format.html { redirect_to(user_instruments_url) }
        format.json { render :json => {"error" => "you do not own this instrument."}, :status => 406 }
      end
    end
  end
  
  # GET /instruments
  def list
    @instruments = Instrument.list(params)
    respond_to do |format|
      format.json { render :json =>@instruments.to_json(:include => :location) }
    end
  end
  
  private

  def rewrite_api_parameters
    return unless request.format == 'application/json'
    params["instrument"] = {} unless params["instrument"]
    ["data_type_id", "deadtime", "error", "location_id", "model", "notes", "new_location"].each do |key|
      params["instrument"][key] = params.delete key
    end
    params["instrument"]["location_attributes"] = {} unless params["instrument"]["location_attributes"]
    ["name", "latitude", "longitude"].each do |key|
      params["instrument"]["location_attributes"][key] = params.delete "location_#{key}"
    end
  end
end
