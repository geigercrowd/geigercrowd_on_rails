class SamplesController < ApplicationController

  respond_to :html
  respond_to :json, except: [ :edit, :new ]
  
  skip_before_filter :authenticate_user!, only: [ :search, :find ]
  before_filter :instrument, except: [ :search, :find ]
  before_filter :rewrite_api_parameters, :only => [:create, :update]
  before_filter :breadcrumb_path, except: [ :search, :find ]
  
  
  # GET /users/hulk/instruments/1/samples
  def index
    @samples = instrument.samples
    respond_with instrument.user, instrument, @samples
  end

  # GET /users/hulk/instruments/1/samples/1
  def show
    @sample = instrument.samples.find params[:id]
    add_breadcrumb @sample.id, polymorphic_path([@origin, @instrument, @sample])
    respond_with @origin, instrument, @sample
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
    @sample.save
    respond_with instrument.user, instrument, @sample do |format|
      format.html do
        if @sample.valid?
          redirect_to action: :new
        else
          render action: :new
        end
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
      @sample.destroy
      respond_with instrument.user, instrument, @sample
    else
      respond_with do |format|
        format.html { render "errors/404", status: :not_found }
        format.json { render json: { errors: { sample: "not found" }}, status: :not_found }
      end
    end
  end
  
  # GET /samples/find
  def find
    options = params[:options] || []
    options = options.split(",") if options.is_a?(String)
    @samples = Sample
    @samples = @samples.nearby(params[:location]) if params[:location].present?
    @samples = @samples.page(params[:page])
    @samples = @samples.latest if options.include?("latest")
    @samples = @samples.after(params[:after].presence || 1.week.ago)
    @samples = @samples.before(params[:before]) if params[:before].present?
    respond_with @samples.all include: [ :data_type, :instrument, :location ]
  end
  
  private

  def breadcrumb_path
    return if request.format == 'application/json'
    if is_owned?
      add_breadcrumb  I18n.t('breadcrumbs.own_instruments'), user_instruments_path(current_user) 
    else
      add_breadcrumb  I18n.t('breadcrumbs.other_instruments', :user => @origin.to_param), polymorphic_path([@origin,Instrument])
    end
    add_breadcrumb (@origin.is_a?(DataSource) ? instrument.location.try(:name) : :instrument_model), polymorphic_path([@origin, instrument])
    add_breadcrumb I18n.t('breadcrumbs.samples'), polymorphic_path([@origin, instrument, Sample])
  end

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
    if ['index', 'show'].include? params[:action]
      @instrument ||= @origin.
        instruments.find(params[:instrument_id])
    else
      @instrument ||= current_user.
        instruments.find(params[:instrument_id])
    end
  rescue
    respond_with do |format|
      format.html { render "errors/403", status: :forbidden }
      format.json { render json: {}, status: :forbidden }
    end
  end
end
