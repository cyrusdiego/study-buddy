class QuizzesController < ApplicationController
  before_action :set_quiz, only: [:show]

  # GET /quizzes/1
  # GET /quizzes/1.json
  def show
    questions_from_contents = @quiz.contents.map(&:questions).flatten
    questions_from_tags = @quiz.tags.map(&:contents).flatten.map(&:questions).flatten
    @questions = questions_from_contents.concat(questions_from_tags).uniq
  end

  # GET /quizzes/new
  def new
    @quiz = Quiz.new
    @quiz.user = current_user
  end

  # POST /quizzes
  # POST /quizzes.json
  def create
    @quiz = Quiz.new(quiz_params)
    @quiz.user = current_user

    respond_to do |format|
      if @quiz.save
        format.html { redirect_to @quiz }
        format.json { render :show, status: :created, location: @quiz }
      else
        format.html { redirect_to contents_url, alert: 'Failed to create quiz.' }
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
    params.require(:quiz).permit(content_ids: [], tag_ids: [])

  end
end
