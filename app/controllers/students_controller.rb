class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :update, :destroy]

  # GET /students
  def index
    @students = Student.all

    render json: @students
  end

  # GET /students/1
  def show
   
    render json: {student: @student, account: @student.credential}
  end
 
  def show_credentials
    @credentials = Credential.all
    render json: @credentials
  end

  # POST /students
  def create
    
    @student = Student.new({level: params[:level], contract: params[:contract]})
    @student.course_id= 1
    if @student.add_credential(params[:email], params[:password], params[:password_confirmation]) #Creamos la credencial y le añadimos el id antes de guardarlo en la base
      if @student.save
        render json: @student, status: :created, location: @student
      else
        render json: @student.errors, status: :unprocessable_entity
      end
    else
      render json: {message: 'Error creating account'}
    end
  end

    # PATCH/PUT /students/1
  def update
    if @student = Student.find(params[:id])
     @student.student_level+=1
     @student.save
     render json: @student
    else
       render json: @student.errors, status: :unprocessable_entity
     end 
  end

  # DELETE /students/1
  def destroy
    @student.delete_credential
    @student.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    
end
