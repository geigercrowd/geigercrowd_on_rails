class SamplesController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.instruments'), :instruments_path
  add_breadcrumb :instrument_model, :instruments_path
  add_breadcrumb I18n.t('breadcrumbs.samples'), :instrument_samples_path

  # GET /instruments/1/samples
  def index
    @instrument = Instrument.first conditions:
      { user_id: current_user.id, id: params[:instrument_id] }
    @samples = @instrument.samples
  end

  # GET /instruments/1/samples/1
  def show
    @instrument = Instrument.first conditions:
      { user_id: current_user.id, id: params[:instrument_id] }
    @sample = Sample.first conditions: {
      id: params[:id], instrument_id: params[:instrument_id], }
    add_breadcrumb @sample.id, :instrument_sample_path
  end

  # GET /instruments/1/samples/new
  def new
    @instrument = Instrument.first conditions:
      { user_id: current_user.id, id: params[:instrument_id] }
    add_breadcrumb I18n.t('new'), :new_instrument_sample_path

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
    add_breadcrumb @sample.id, :instrument_sample_path
    add_breadcrumb I18n.t('edit'), :edit_instrument_sample_path
  end

  # POST /instruments/1/samples
  def create
    @instrument = Instrument.find params["instrument_id"]
    @sample = @instrument.samples.new params[:sample]
    if @sample.save
      redirect_to new_instrument_sample_path,
        :notice => 'Sample was successfully created'
    else
      render :action => "new"
    end
  end

  # PUT /instruments/1/samples/1
  def update
    @sample = Sample.find(params[:id])
    if @sample.update_attributes(params[:sample])
      redirect_to [ @sample.instrument, @sample ],
        notice: 'Sample was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /instruments/1/samples/1
  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy
    redirect_to instrument_samples_path @sample.instrument
  end
end
