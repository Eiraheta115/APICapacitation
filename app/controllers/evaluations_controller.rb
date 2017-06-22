class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:show, :update, :destroy]

  # GET /evaluations
  # def index
  #   @evaluations = Evaluation.all

  #   render json: @evaluations
  # end

  def getTest
    #@module = CourseModule.find(params[:module_id])

    @evaluation = Evaluation.find(params[:module_id])
    @letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    @test = []
    @count=0
    @correlativeQuestions = []
    @CorrelativeLink = []
    #For Simple and multiple questions
    @questions = Question.where("evaluation_id = :id and (question_type = :question_typeM or question_type = :question_typeL)", { id: @evaluation.id, question_typeM: "multiple", question_typeL: "simple" })
    #@questions = Question.where(evaluation_id: @evaluation.id) I'm not gonna use it anymore
     @questions.each do |q|
       @correlativeQuestions.clear
       @answers = Answer.where(question_id: q.id)
       @answers.shuffle.each do |a| 
        @correlativeQuestions << CorrelativeQ.new(@letters[@count], a.id, a.answer_statement)
        @count+=1
       end #answer loop
       @test << TestQuestion.new(q.id, q.question_type, q.question_statement, @correlativeQuestions.take(@correlativeQuestions.size))
       @count=0
     end #questions loop

     #Procedure of getting Link questions
     @count=0
     @questionsLink = Question.where(evaluation_id: @evaluation.id, question_type: "link")
     @questionsLinkCorrelative = @questionsLink.select(:link_question_correlative).distinct
     @questionsLinkCorrelative.each do |qL|
      @correlativeQuestions.clear
      @CorrelativeLink.clear
      @Linkq = Question.where(evaluation_id: @evaluation.id, link_question_correlative: qL.link_question_correlative)
      
      @Linkq.each do |link|
      @CorrelativeLink << CorrelativeLinkQ.new(link.question_statement)
      end 
      @questionsLink.where(link_question_correlative: @questionsLinkCorrelative).each do |aL|
      @answersLink = Answer.where(question_id: aL.id)
       @answersLink.shuffle.each do |aL| 
        @correlativeQuestions << CorrelativeQ.new(@letters[@count], aL.id,  aL.answer_statement)
        @count+=1
       end #answer loop
       
     end
      @test << TestQuestion.new(qL.link_question_correlative, "link", @CorrelativeLink.take(@CorrelativeLink.size), @correlativeQuestions.take(@correlativeQuestions.size))
     
     end #end link questions loop

    render :json => {
      :evaluation_time => @evaluation.evaluation_time,
      :testQuestions => @test.shuffle,
      }
  end

  def getScore
    @total_counter=0
    @pattern = []
    @yourAnswers = []
    @correctAnswers = []
    @i=0
    @totalGrade=0
    @totalQuestion=0
    @evaluation= Evaluation.find(params[:evaluation_id])
    @try = JSON.parse(request.body.string) 
    @test = @try['testQuestions']
    @counterDB= Question.where(evaluation_id: @evaluation.id).count
    @counterJson=0 #@test[1]['question'].count
    @linkCorrelativeCounter=0
    @i=0
       while @i<@test.size do
         if @test[@i]['type']=="link"
              @linkCorrelativeCounter+=1
              @counterJson+=@test[@i]['question'].count
         end  #end if
         @i+=1
       end #end test loop 
    @counterJson+=@test.count-@linkCorrelativeCounter

    if @counterDB==@counterJson
      @i=0
      @a=0
      @flag=0
      while @i<@try['testQuestions'].size       
      if @try['testQuestions'][@i]['type']=="simple" or @try['testQuestions'][@i]['type']=="multiple"
        while @a < @try['testQuestions'][@i]['answers'].size 
         if @try['testQuestions'][@i]['answers'][@a]['correct']== true 
          @total_counter+=1
          @yourAnswers << @try['testQuestions'][@i]['answers'][@a]['answers']
          @ansDB=Answer.find_by(id: @try['testQuestions'][@i]['answers'][@a]['id'])
          @response =@ansDB.correct_answer
          @cAns=Answer.where(question_id: @try['testQuestions'][@i]['id'], correct_answer: true)
          if @response==true
            @totalQuestion+=1.00
          end #end if response
         end #end if json
        @a +=1
        end #end answers while
        
     @cAns.each do |ca|
      @correctAnswers << ca.answer_statement
     end # end loop 
     if @total_counter>@cAns.size
      @totalQuestion=0
    end
     @pattern << Pattern.new(@try['testQuestions'][@i]['question'],@yourAnswers.take(@yourAnswers.size),@correctAnswers.take(@correctAnswers.size), (@totalQuestion/@cAns.size).round(2)) 
     @total_counter=0
     @a=0
     @i+=1 
     @totalGrade+=(@totalQuestion/@cAns.size).round(2)  
     @totalQuestion=0.00
     @yourAnswers.clear
     @correctAnswers.clear
    else
     while @a < @try['testQuestions'][@i]['answers'].size 
          
     if @try['testQuestions'][@i]['answers'][@a]['correct']== true 
      @total_counter+=1
      @yourAnswers << @try['testQuestions'][@i]['answers'][@a]['answers']
      @ansDB=Answer.find_by(id: @try['testQuestions'][@i]['answers'][@a]['id'])
      @response =@ansDB.correct_answer
           
      if @response==true
       @totalQuestion+=1.00
      end #end if response
     end #end if json
     @a +=1

     end #end answers while
     @cAnsLINK = []
     @questionsLINK= Question.where(link_question_correlative: @try['testQuestions'][@i]['id'])
      @questionsLINK.each do |qL| 
       @answersLINK=Answer.where(question_id: qL.id, correct_answer: true)
       @answersLINK.each do |aL|
       @cAnsLINK << aL.answer_statement
      end
     end 
    if @total_counter>@cAnsLINK.size
      @totalQuestion=0
    end
    @pattern << Pattern.new(@try['testQuestions'][@i]['question'],@yourAnswers.take(@yourAnswers.size),@cAnsLINK.take(@cAnsLINK.size), (@totalQuestion/@cAnsLINK.size).round(2)) 
    @a=0
    @total_counter=0
    @i+=1 
    @totalGrade+=(@totalQuestion/@cAnsLINK.size).round(2)
        
    @totalQuestion=0.00
    @yourAnswers.clear
    @correctAnswers.clear
       
    end
    end #end questions while
      
  end 

    render :json => {
      :Grade => (@totalGrade/@test.count*10).round(2),
      :pattern =>@pattern
      }
  end 

 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def evaluation_params
      params.require(:evaluation).permit(:course_module_id, :evaluation_time, :evaluation_q_link_questions)
    end
end
