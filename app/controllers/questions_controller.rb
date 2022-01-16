class QuestionsController < ApplicationController
  before_action :set_question, only: [:destroy]
  before_action :set_content, only: [:create]

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)
    byebug

    # TODO: Below
    # respond_to do |format|
    #   if @question.save
    #     format.html { redirect_to @content, notice: 'Content was successfully created.' }
    #     format.json { render :show, status: :created, location: @content }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @content.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    #TODO
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_question
    @question = Question.find(params[:id])
  end

  def set_content
    @content = Content.find(params[:content_id])
  end

  # Only allow a list of trusted parameters through.
  def question_params
    params.require(:question).permit(:question)
  end
end
