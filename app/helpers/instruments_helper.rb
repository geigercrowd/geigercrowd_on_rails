module InstrumentsHelper
  def instrument_options instruments
    instruments.collect do |i|
      [ i.model, i.id ]
    end
  end

  def instrument_model
    @instrument.model
  end
end
