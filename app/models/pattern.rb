class Pattern 
	attr_accessor :question, :youranswer, :correctans, :score

	def initialize(question, youranswer, correctans, score)
    @question = question
    @youranswer = youranswer
    @correctans = correctans 
    @score = score
  end
end
