class SourcesController < ApplicationController
  respond_to :html
  skip_before_filter :authenticate_user!
  
  add_breadcrumb I18n.t('breadcrumbs.sources'), :data_sources_path

  # GET /sources
  def index
    @sources = DataSource.all
  end
end
