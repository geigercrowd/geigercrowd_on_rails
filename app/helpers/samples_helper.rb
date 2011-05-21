module SamplesHelper
  def sort_by_header order
    current_order = @search_params[:order]
    order = current_order == order ? "#{order}_desc" : order
    link_to order, samples_path(@search_params.merge(order: order, page: 1))
  end
end
