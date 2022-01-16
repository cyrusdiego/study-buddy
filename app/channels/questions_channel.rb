class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "questions_#{params[:content_id]}"
  end
end
