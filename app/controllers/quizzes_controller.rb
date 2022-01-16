class QuizzesController < ApplicationController
  before_action :set_quiz, only: [:show]

  # GET /quizzes/1
  # GET /quizzes/1.json
  def show
  end

  # GET /quizzes/new
  def new
    @quiz = Quiz.new
    @quiz.user = current_user
  end

  # POST /quizzes
  # POST /quizzes.json
  def create
    # TODO
    @quiz = Content.new(content_params)
    @quiz.user = current_user

    respond_to do |format|
      if @quiz.save
        format.html { redirect_to @quiz, notice: 'Content was successfully created.' }
        format.json { render :show, status: :created, location: @quiz }
      else
        format.html { render :new }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def quiz_params
    params.require(:quiz).permit
  end
end
