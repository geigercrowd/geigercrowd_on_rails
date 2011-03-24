module DataTypesHelper
  def data_type_options data_types
    data_types.collect do |d|
      [ d.si_unit, d.id ]
    end
  end
end
