class SamplesController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.instruments'), :user_instruments_path
  add_breadcrumb :instrument_model, :user_instruments_path
  add_breadcrumb I18n.t('breadcrumbs.samples'), :user_instrument_samples_path

  before_filter :rewrite_api_parameters, :only => [:create, :update]

  # GET /instruments/1/samples
  def index
    @instrument = Instrument.first conditions:
      { user_id: current_user.id, id: params[:instrument_id] }
    @samples = @instrument.samples
    respond_to do |format|
      format.html 
      format.json { render :json =>@samples }
    end
  end

  # GET /instruments/1/samples/1
  def show
    @instrument = Instrument.first conditions:
      { user_id: current_user.id, id: params[:instrument_id] }
    @sample = Sample.first conditions: {
      id: params[:id], instrument_id: params[:instrument_id], }
    
    respond_to do |format|
      format.html { add_breadcrumb @sample.id, :user_instrument_sample_path }
      format.json { render :json =>@sample }
    end
  end

  # GET /instruments/1/samples/new
  def new
    @instrument = Instrument.first conditions:
      { user_id: current_user.id, id: params[:instrument_id] }
    add_breadcrumb I18n.t('breadcrumbs.new'), :new_user_instrument_sample_path

    if @instrument.nil?
      flash[:error] = t('samples.new.add_instrument_notice', link: new_instrument_path)
      redirect_to new_instrument_path
    else
      @sample = Sample.new instrument_id: @instrument.id,
        location: @instrument.location || Location.new
    end
  end

  # GET /instruments/1/samples/1/edit
  def edit
    @instrument = Instrument.first conditions:
      { user_id: current_user.id, id: params[:instrument_id] }
    @instruments = current_user.instruments
    @data_types = DataType.all
    @sample = Sample.find(params[:id])
    @locations = current_user.locations
    add_breadcrumb @sample.id, :user_instrument_sample_path
    add_breadcrumb I18n.t('edit'), :edit_user_instrument_sample_path
  end

  # POST /instruments/1/samples
  def create
    @sample = current_user.instruments.find(params[:instrument_id]).
      samples.new(params[:sample]) rescue nil
    if @sample && @sample.save
      respond_to do |format|
        format.html { 
          redirect_to new_user_instrument_sample_path,
            :notice => I18n.t('.successfully_created')
        }
        format.json { render :json =>@sample }
      end
    else
      respond_to do |format|
        format.html { redirect_to :root }
        format.json { render :json => (@sample ? @sample.errors : {:instrument_id => "was not found"}), :status => 406  }
      end
    end
  end

  # PUT /instruments/1/samples/1
  def update
    @sample = current_user.instruments.find(params[:instrument_id]).
      samples.find(params[:id]) rescue nil
    if @sample && @sample.update_attributes(params[:sample])
      respond_to do |format|
        format.html { 
          redirect_to [ current_user, @sample.instrument, @sample ],
            notice: 'Sample was successfully updated.'
        }
        format.json { render :json =>@sample }
      end
    else
      respond_to do |format|
        format.html { redirect_to :root }
        format.json { render :json => (@sample ? @sample.errors : {:instrument_id => "was not found"}), :status => 406  }
      end
    end
  end

  # DELETE /instruments/1/samples/1
  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy
    
    respond_to do |format|
      format.html { redirect_to user_instrument_samples_path current_user, @sample.instrument }
      format.json { render :json => @sample }
    end
  end
  
  private

  def rewrite_api_parameters
    return unless request.format == 'application/json'
    params["sample"] = {} unless params["sample"]
    ["timestamp", "value", "timezone"].each do |key|
      params["sample"][key] = params.delete key
    end

  end
end
