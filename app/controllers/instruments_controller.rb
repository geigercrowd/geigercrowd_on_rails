class InstrumentsController < ApplicationController

  respond_to :html, except: [ :list ]
  respond_to :json, except: [ :edit, :new ]

  before_filter :rewrite_api_parameters, :only => [:create, :update]
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :ensure_owned, :except => [:index, :show, :list]
  before_filter :breadcrumb

  def breadcrumb
    return if request.format == 'application/json'
    if is_owned?
      add_breadcrumb  I18n.t('breadcrumbs.own_instruments'), user_instruments_path(current_user)
    else
      add_breadcrumb  I18n.t('breadcrumbs.other_instruments', :user => @origin.to_param), polymorphic_path([@origin,Instrument])
    end
  end
  
  # GET /users/hulk/instruments
  def index
    @instruments = @origin.instruments
    @instruments = @instruments.paginate page: params[:page]
    respond_with @instruments do |format|
      format.html do
        if is_owned? && @instruments.empty?
          redirect_to action: :new
        else
          render
        end
      end
    end
  end

  # GET /users/hulk/instruments/1
  def show
    @instrument = @origin.instruments.find(params[:id]) rescue nil
    if @instrument
      respond_with @instrument do |format|
        format.html do
          add_breadcrumb @origin.is_a?(DataSource) ?
            @instrument.location.try(:name) : @instrument.model,
            polymorphic_path([@origin,@instrument])
        end
        format.json { render json: @instrument }
      end
    else
      respond_with do |format|
        format.html do
          flash[:error] = I18n.t('not_found', resource: Instrument)
          redirect_to [ @origin, Instrument ]
        end
        format.json { render json: { errors: [ "Instrument not found" ]},
                             status: :not_found }
      end
    end
  end

  # GET /users/hulk/instruments/new
  def new
    @instrument = current_user.instruments.new location: Location.new
    @data_types = DataType.all
    respond_with @instrument do |format|
      format.html do
        add_breadcrumb I18n.t('new'), :new_user_instrument_path
        flash[:notice] = I18n.t('instruments.create_first') if current_user.instruments.empty?
      end
    end
  end

  # GET /users/hulk/instruments/1/edit
  def edit
    @instrument = current_user.instruments.find params[:id] rescue nil
    if @instrument
      @data_types = DataType.all
      @instrument.location ||= Location.new
      respond_with @instrument do |format|
        format.html do
          add_breadcrumb @instrument.model, :user_instrument_path
          add_breadcrumb I18n.t('edit'), :edit_user_instrument_path
        end
      end
    else
      respond_with do |format|
        format.html do
          flash[:error] = I18n.t('not_found', :resource => Instrument)
          redirect_to [ @origin, Instrument ]
        end
        format.json do
          render json: { errors: [ "Instrument not found" ]}, status: 404
        end
      end
    end
  end

  # POST /users/hulk/instruments
  def create
    if is_owned?
      @instrument = current_user.instruments.create params[:instrument]
      respond_with current_user, @instrument
    else
      respond_with do |format|
        format.html { redirect_to "errors/401" }
        format.json { render :json => { errors: ["Permission denied"] }}
      end
    end
  end

  # PUT /users/hulk/instruments/1
  def update
    @instrument = Instrument.find params[:id]
    if @instrument.user == current_user
      if @instrument.update_attributes params[:instrument]
        respond_to do |format|
          format.html { redirect_to [current_user, @instrument], :notice => t('instruments.update.successful') }
          format.json { render :json =>@instrument }
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

  # DELETE /users/hulk/instruments/1
  def destroy
    @instrument = current_user.instruments.where(:id => params[:id]).first
    if @instrument
      @instrument.destroy
      respond_to do |format|
        format.html { redirect_to(user_instruments_url) }
        format.json { render :json =>@instrument }
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
    @instruments = Instrument
    @instruments = @instruments.after(params[:after].presence || 1.week.ago)
    @instruments = @instruments.before(params[:before]) if params[:before].present?
    @instruments = @instruments.paginate page:  params[:page],
                                         order: "updated_at desc",
                                         per_page: Instrument.per_page
    respond_with @instruments
  end
  
  private

  def rewrite_api_parameters
    return unless request.format == 'application/json'
    params[:instrument] = {} unless params[:instrument]
    ["data_type_id", "deadtime", "error", "location_id", "model", "notes", "new_location"].each do |key|
      params["instrument"][key] = params.delete key
    end
    if params[:location]
      params[:instrument].update(location_attributes: params[:location])
    end
  end
end
