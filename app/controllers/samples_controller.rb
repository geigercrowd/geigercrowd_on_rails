class SamplesController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.instruments'), :instruments_path
  add_breadcrumb :instrument_model, :instruments_path
  add_breadcrumb I18n.t('breadcrumbs.samples'), :instrument_samples_path

  # GET /samples
  def index
    @instrument = Instrument.first conditions:
      { user: current_user, id: params[:instrument_id] }
    @samples = @instrument.samples
  end

  # GET /samples/1
  def show
    @instrument = Instrument.first conditions:
      { user: current_user, id: params[:instrument_id] }
    @sample = @instrument.samples.select { |s| s.id = params[:id] }
    add_breadcrumb @sample.id, :instrument_sample_path
  end

  # GET /instrument/1/samples/new
  def new
    @instrument = current_user.instruments.select do |i|
      i.id == params["instrument_id"].to_i
    end.first
    add_breadcrumb I18n.t('new'), :new_instrument_sample_path

    if @instrument.nil?
      flash[:error] = t('samples.new.add_instrument_notice', link: new_instrument_path)
      redirect_to new_instrument_path
    else
      @sample = Sample.new instrument_id: @instrument.id,
        location: @instrument.location || Location.new
    end
  end

  # GET /samples/1/edit
  def edit
    @instruments = current_user.instruments
    @data_types = DataType.all
    @sample = Sample.find(params[:id])
    @locations = current_user.locations
    add_breadcrumb @sample.id, :instrument_sample_path
    add_breadcrumb I18n.t('edit'), :edit_instrument_sample_path
  end

  # POST /samples
  def create
    @instrument = Instrument.find params["instrument_id"]
    @sample = Sample.new(params[:sample])
    if @sample.save
      @instrument.samples << @sample
      redirect_to new_instrument_sample_path,
        :notice => 'Sample was successfully created'
    else
      render :action => "new"
    end
  end

  # PUT /samples/1
  def update
    @sample = Sample.find(params[:id])
    if @sample.update_attributes(params[:sample])
      redirect_to(@sample, :notice => 'Sample was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /samples/1
  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy
    redirect_to(samples_url)
  end
end
