class SamplesController < ApplicationController
  # GET /samples
  def index
    @samples = current_user.samples
  end

  # GET /samples/1
  def show
    @sample = Sample.find(params[:id])
  end

  # GET /samples/new
  def new
    @instruments = current_user.instruments
    @data_types = DataType.all
    @locations = current_user.locations
    @sample = Sample.new
    if current_user.instruments.empty?
      flash[:error] = t 'sample.new.add_instrument_notice'
    end

  end

  # GET /samples/1/edit
  def edit
    @instruments = current_user.instruments
    @data_types = DataType.all
    @sample = Sample.find(params[:id])
    @locations = current_user.locations
  end

  # POST /samples
  def create
    @sample = Sample.new(params[:sample])
    @sample.user_id = current_user.id

    if @sample.save
      redirect_to new_sample_path,
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
