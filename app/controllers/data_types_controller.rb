class DataTypesController < ApplicationController
  before_filter :admin_only

  # GET /data_types
  def index
    @data_types = DataType.all
  end

  # GET /data_types/1
  def show
    @data_type = DataType.find(params[:id])
  end

  # GET /data_types/new
  def new
    @data_type = DataType.new
  end

  # GET /data_types/1/edit
  def edit
    @data_type = DataType.find(params[:id])
  end

  # POST /data_types
  def create
    @data_type = DataType.new(params[:data_type])

    if @data_type.save
      redirect_to @data_type, :notice => 'Data type was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /data_types/1
  def update
    @data_type = DataType.find(params[:id])

    if @data_type.update_attributes(params[:data_type])
      redirect_to(@data_type, :notice => 'Data type was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /data_types/1
  def destroy
    @data_type = DataType.find(params[:id])
    @data_type.destroy

    redirect_to(data_types_url)
  end
end
