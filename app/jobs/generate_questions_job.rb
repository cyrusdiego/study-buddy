class GenerateQuestionsJob < ApplicationJob
  queue_as :default

  # method is :one_per_page or :one_randomly
  def perform(content_id, method)
    # Load up the file with the associated content model
    content = Content.find(content_id)
    content.file.open do |f|
      f.binmode
      r = PDF::Reader.new(f)
      puts r.page_count

      case method
      when :one_per_page
        r.pages.each do |page|
          # TODO: Call OpenAI with this pages text
          puts page.text
          question_text = 'todo dynamically generate this'
          begin
            create_question(content_id, question_text)
          rescue
            puts 'Failed to create a question'
          end
        end

      when :one_randomly
        page = r.pages[rand(0..(r.page_count - 1))]
        # TODO: Call OpenAI with this pages text
        puts page.text
        question_text = 'todo dynamically generate this'
        begin
          create_question(content_id, question_text)
        rescue
          puts 'Failed to create a question'
        end
      else
        raise 'Invalid method'
      end
    end
  end

  def create_question(content_id, question_text)
    question = Question.new
    question.content_id = content_id
    question.question = question_text
    question.save!
  end
end
