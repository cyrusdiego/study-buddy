require "openai_api"

class GenerateQuestionsJob < ApplicationJob
  queue_as :default

  # method is :per_page or :random_page
  def perform content_id, method
    # Load up the file with the associated content model
    content = Content.find content_id
    content.file.open do |f|
      f.binmode
      r = PDF::Reader.new f

      case method
      when :per_page
        r.pages.each do |page|
          self.create_questions content_id, page.text
        end

      when :random_page
        page = r.pages[rand(0..(r.page_count - 1))]
        self.create_questions content_id, page.text
        ß
      else
        raise Exception.new "Invalid method for CreateQuestionsJob."
      end
    end
  end

  private

  def create_questions content_id, page_text
    begin
      question_set = OpenAiApi.fetch_question_set page_text
    rescue Exception => ex
      raise Exception.new "Error encountered while fetching question set.\n%{error_info}" %
                            { error_info: ex.inspect }
    end

    begin
      question_set.each do |question|
        # TODO: Generate answer for question
        answer = "TODO: Generate this dynamically"
        self.create_question content_id, question, answer
      end
    rescue Exception => ex
      raise Exception.new "Failed to create a question from GenerateQuestionsJob.\n%{err}" % { err: ex.inspect }
    end
  end

  def create_question content_id, question_text, answer_text
    question = Question.new
    question.content_id = content_id
    question.question = question_text
    question.answer = answer_text
    question.save!
  end
end
