class QuestionsController < ApplicationController
  before_action :set_question, only: [:destroy]
  before_action :set_content, only: [:create]

  # TODO: Refactor this
  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to @content, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { redirect_to @content, alert: 'Failed to create question.' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # TODO: Refactor this
  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to contents_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
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
