class InstrumentsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.instruments'), Proc.new { |c| c.user_instruments_path(c.current_user) }
  
  before_filter :rewrite_api_parameters, :only => [:create, :update]
  
  # GET /instruments
  def index
    @instruments = current_user.instruments
    
    respond_to do |format|
      format.html
      format.json { render :json =>@instruments.to_json(:include => :location) }
    end
  end

  # GET /instruments/1
  def show
    @instrument = Instrument.find(params[:id])
    respond_to do |format|
      format.html { add_breadcrumb @instrument.model, :user_instrument_path }
      format.json { render :json =>@instrument.to_json(:include => :location) }
    end
  end

  # GET /instruments/new
  def new
    @data_types = DataType.all
    @instrument = Instrument.new
    @instrument.location = Location.new
    @locations = current_user.locations
    add_breadcrumb I18n.t('new'), :new_user_instrument_path
  end

  # GET /instruments/1/edit
  def edit
    @data_types = DataType.all
    @instrument = Instrument.find(params[:id])
    @instrument.location ||= Location.new
    add_breadcrumb @instrument.model, :user_instrument_path
    add_breadcrumb I18n.t('edit'), :edit_user_instrument_path
  end

  # POST /instruments
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

  # PUT /instruments/1
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

  # DELETE /instruments/1
  def destroy
    @instrument = Instrument.find(params[:id])
    @instrument.destroy
    
    respond_to do |format|
      format.html { redirect_to(user_instruments_url) }
      format.json { render :json =>@instrument.to_json(:include => :location)}
    end
  end
  
  private

  def rewrite_api_parameters
    return unless request.format == 'application/json'
    params["instrument"] = {} unless params["instrument"]
    ["data_type_id", "deadtime", "error", "location_id", "model", "notes"].each do |key|
      params["instrument"][key] = params.delete key
    end
    params["instrument"]["location_attributes"] = {} unless params["instrument"]["location_attributes"]
    ["name", "latitude", "longitude"].each do |key|
      params["instrument"]["location_attributes"][key] = params.delete "location_#{key}"
    end
  end
end
