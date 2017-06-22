class CorrelativeQ 
attr_accessor :answers, :id, :correct

  # Constructor
  def initialize(correlative, id, answers)
  	@id = id
    @correlative = correlative  # A Statement object or a string.
    @answers = answers  # A Statement object or a string.
  end
end


