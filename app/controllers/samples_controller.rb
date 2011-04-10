class SamplesController < ApplicationController

  respond_to :html
  respond_to :json, except: [ :edit, :new ]
  
  before_filter :instrument
  before_filter :rewrite_api_parameters, :only => [:create, :update]
  skip_before_filter :authenticate_user!, :only => [:index, :show]
 # before_filter :ensure_owned, :except => [:index, :show, :list]
  before_filter :breadcrumb

  def breadcrumb
    return
    return if request.format == 'application/json'
    if is_owned?
      add_breadcrumb  I18n.t('breadcrumbs.own_instruments'), Proc.new { |c| c.user_instruments_path(c.current_user) }
    else
      add_breadcrumb  I18n.t('breadcrumbs.other_instruments', :user => User.find_by_screen_name(@user_id).screen_name), Proc.new { |c| c.user_instruments_path(@user_id) }
    end
    add_breadcrumb :instrument_model, :user_instruments_path
    add_breadcrumb I18n.t('breadcrumbs.samples'), :user_instrument_samples_path
  end
  
  
  # GET /users/hulk/instruments/1/samples
  def index
    @samples = instrument.samples
    respond_with instrument.user, instrument, @samples
  end

  # GET /users/hulk/instruments/1/samples/1
  def show
    @sample = instrument.samples.find params[:id]
    add_breadcrumb @sample.id, :user_instrument_sample_path
    respond_with instrument.user, instrument, @sample
  end

  # GET /users/hulk/instruments/1/samples/new
  def new
    add_breadcrumb I18n.t('breadcrumbs.new'),
      new_user_instrument_sample_path(instrument.user, instrument)
    location = instrument.location || Location.new
    @sample = instrument.samples.new location: location
    respond_with instrument.user, instrument, @sample
  end

  # GET /user/hulk/instruments/1/samples/1/edit
  def edit
    @sample = instrument.samples.find params[:id] rescue nil

    if @sample
      add_breadcrumb @sample.id,
        user_instrument_sample_path(instrument.user, instrument, @sample)
      add_breadcrumb I18n.t('edit'),
        edit_user_instrument_sample_path(instrument.user, instrument, @sample)
      respond_with instrument.user, instrument, @sample
    else
      respond_with do |format|
        format.html { redirect_to "errors/404" }
      end
    end
  end

  # POST /users/hulk/instruments/1/samples
  def create
    Time.zone = params[:sample][:timezone] if params[:sample] &&
      params[:sample][:timezone]

    @sample = instrument.samples.new params[:sample]
    @sample.save_as current_user
    respond_with instrument.user, instrument, @sample do |format|
      format.html do
        redirect_to new_user_instrument_sample_path(instrument.user, instrument)
      end
    end
  end

  # PUT /users/hulk/instruments/1/samples/1
  def update
    Time.zone = params[:sample][:timezone] if params[:sample] and params[:sample][:timezone]

    @sample = instrument.samples.find(params[:id]) rescue nil

    if @sample && @sample.update_attributes(params[:sample])
      respond_with instrument.user, instrument, @sample do |format|
        format.json { render json: @sample }
      end
    else
      respond_with do |format|
        format.html { render "errors/404", status: :not_found }
        format.json { render :json => { errors: {:sample => "not found"}, :status => :not_found }}
      end
    end
  end

  # DELETE /users/hulk/instruments/1/samples/1
  def destroy
    @sample = instrument.samples.find params[:id] rescue nil
    if @sample
      @sample.destroy_as current_user
      respond_with instrument.user, instrument, @sample
    else
      respond_with do |format|
        format.html { render "errors/404", status: :not_found }
        format.json { render json: { errors: { sample: "not found" }}, status: :not_found }
      end
    end
  end
  
  # GET /instruments
  def list
    @samples = Sample.list(params)
    respond_with @samples
  end
  
  private

  def rewrite_api_parameters
    return unless request.format == 'application/json'
    params[:sample] = {} unless params[:sample]
    ["timestamp", "value", "timezone"].each do |key|
      params["sample"][key] = params.delete key
    end
    if params[:location]
      params[:sample].update(location_attributes: params[:location])
    end
  end

  def instrument
    @instrument ||= User.find_by_screen_name(params[:user_id]).
      instruments.find(params[:instrument_id])
  rescue
    respond_with do |format|
      format.html { render "errors/403", status: :forbidden }
      format.json { render json: {}, status: :forbidden }
    end
  end
end
