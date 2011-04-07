class SamplesController < ApplicationController

  respond_to :html
  respond_to :json, except: [ :edit, :new ]
  
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
  
  
  # GET /instruments/1/samples
  def index
    @instrument = Instrument.first conditions: { id: params[:instrument_id] }
    @samples = @instrument.samples
    respond_to do |format|
      format.html 
      format.json { render :json =>@samples }
    end
  end

  # GET /instruments/1/samples/1
  def show
    @instrument = Instrument.first conditions:
      { id: params[:instrument_id] }
    @sample = Sample.first conditions: {
      id: params[:id], instrument_id: params[:instrument_id], }
    
    respond_to do |format|
      format.html { add_breadcrumb @sample.id, :user_instrument_sample_path }
      format.json { render :json =>@sample }
    end
  end

  # GET /instruments/1/samples/new
  def new
    instrument = current_user.instruments.find params[:instrument_id]

    if instrument.nil?
      flash[:error] = t('samples.new.add_instrument_notice',
                        link: new_user_instrument_path(current_user))
      redirect_to new_user_instrument_path(current_user)
    else
      add_breadcrumb I18n.t('breadcrumbs.new'),
        new_user_instrument_sample_path(current_user, instrument)
      @sample = instrument.samples.new location: Location.new
      respond_with @sample
    end
  end

  # GET /user/hulk/instruments/1/samples/1/edit
  def edit
    @sample = current_user.samples.first conditions:
      { instrument_id: params[:instrument_id] }

    if @sample
      add_breadcrumb @sample.id,
        user_instrument_sample_path(current_user, @sample.instrument, @sample)
      add_breadcrumb I18n.t('edit'),
        edit_user_instrument_sample_path(current_user, @sample.instrument, @sample)
      respond_with @sample
    else
      respond_with do |format|
        format.html { render text: "Unauthorized!", layout: true, status: :unauthorized }
      end
    end
  end

  # POST /instruments/1/samples
  def create
    Time.zone = params[:sample][:timezone] if params[:sample] && params[:sample][:timezone]
    @sample = current_user.instruments.find(params[:instrument_id]).
      samples.new(params[:sample]) rescue nil
    if @sample && @sample.save
      respond_with(@sample) do |format|
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
    Time.zone = params[:sample][:timezone] if params[:sample] and params[:sample][:timezone]
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
    @sample = current_user.samples.where(:id => params[:id]).first
    if @sample
      @sample.destroy
      respond_to do |format|
        format.html { redirect_to user_instrument_samples_path current_user, @sample.instrument }
        format.json { render :json => @sample }
      end
    else
      respond_to do |format|
        format.html { redirect_to user_instrument_samples_path current_user, params[:instrument_id] }
        format.json { render :json => {"error" => "you do not own this sample."}, :status => 406 }
      end
    end
  end
  
  # GET /instruments
  def list
    @samples = Sample.list(params)
    respond_to do |format|
      format.json { render :json =>@samples.to_json(:include => :location) }
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
