class InstrumentsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.instruments'), :instruments_path

  # GET /instruments
  def index
    @instruments = current_user.instruments
    
    respond_to do |format|
      format.html
      format.json { render :json =>@instruments }
    end
  end

  # GET /instruments/1
  def show
    @instrument = Instrument.find(params[:id])
    respond_to do |format|
      format.html { add_breadcrumb @instrument.model, :instrument_path }
      format.json { render :json =>@instrument }
    end
  end

  # GET /instruments/new
  def new
    @data_types = DataType.all
    @instrument = Instrument.new
    @instrument.location = Location.new
    @locations = current_user.locations
    add_breadcrumb I18n.t('new'), :new_instrument_path
  end

  # GET /instruments/1/edit
  def edit
    @data_types = DataType.all
    @instrument = Instrument.find(params[:id])
    @instrument.location ||= Location.new
    add_breadcrumb @instrument.model, :instrument_path
    add_breadcrumb I18n.t('edit'), :edit_instrument_path
  end

  # POST /instruments
  def create
    @instrument = Instrument.create(params[:instrument])
    current_user.instruments << @instrument
    if @instrument.valid?
      respond_to do |format|
        format.html { redirect_to @instrument, :notice => t('instruments.create.successful') }
        format.json { render :json => @instrument }
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
          format.html { redirect_to @instrument, :notice => t('.success_message') }
          format.json { render :json => @instrument }
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
      format.html { redirect_to(instruments_url) }
      format.json { render :json => @instrument}
    end
  end
end
