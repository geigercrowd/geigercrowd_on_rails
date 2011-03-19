class LocationsController < ApplicationController
  # GET /locations
  def index
    @locations = current_user.locations
  end

  # GET /locations/1
  def show
    @location = Location.find(params[:id])
  end

  # GET /locations/new
  def new
    if current_user.locations.empty?
      flash[:notice] = t 'locations.new.add_location_notice'
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  def create
    @location = Location.create(params[:location])
    current_user.locations << @location
    if @location.valid?
      redirect_to locations_path,
        :notice => t('locations.create.successful')
    else
      render :action => "new"
    end
  end

  # PUT /locations/1
  def update
    @location = location.find(params[:id])
    if @location.update_attributes(params[:location])
      redirect_to(@location, :notice => 'location was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /locations/1
  def destroy
    @location = location.find(params[:id])
    @location.destroy
    redirect_to(locations_url)
  end
end
