class TestQuestion 
	attr_accessor :id, :type, :question, :answers

  # Constructor
  def initialize(id, type, question, answers)
  	@id = id # A Statement object or a string.
    @type = type # A Statement object or a string.
    @question = question  # A Statement object or a string.
    @answers = answers  # A Statement object or a string.
  end
end
