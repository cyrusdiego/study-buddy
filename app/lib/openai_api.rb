require "singleton"
require "ruby/openai"

=begin
TODOs

- overall
  - make openaiclient private?
- question gen
  - open ai related
    - refine question gen prompt
    - tweak params
- answer gen
  - open ai related
    - create answer gen prompt
    - tweak params (try question engine instead?)
=end

module OpenAiApiParameters 
  @@question_gen_prompt = "Create a list of questions based on the content

Content:
Technology is the system/tool we used to solve problems. Education is one of the greatest technologies ever created (students are the product of this technological system). Government is another form of technology. Both the above are considered invisible technologies (systems that do not necessarily produce physical objects).
Questions:
What could be considered one of the greatest technologies ever created?
What is the class of technologies that does not produce physical objects?

Content:
Herbert Butterfield's Perspective on Science and Technology
- Argued that external factors have no impact on progress of science and technology (all internal) 
- Argued that what we should study is what scientists do internally within science (he was a physicist so he focused specifically on that field) 
- Was a prominent way of looking at science and our relationship with it for a long time but not anymore 
Questions:
Did Herbert Butterfield believe that external factors had an impact on science and technology?
Is the belief that scientific and technological progress is not impacted by external factors prominent now?

Content:
Machine 
A Turing machine is an abstract computational model that performs computations by reading and writing to an infinite tape. Turing machines provide a powerful computational model for solving problems in computer science and testing the limits of computation. Turing machines are similar to finite automata/finite state machines but have the advantage of unlimited memory. They are capable of simulating common computers; a problem that a common computer can solve (given enough memory) will also be solvable using a Turing machine, and vice versa. Turing machines were invented by the esteemed computer scientist Alan Turing in 1936.
Questions:
What is a Turing machine?
Are Turing machines capable of solving all problems that a common computer can solve (given enough memory)?
Who invented the Turing machine?

Content:
Machine Learning and Types of Learning
- More than one type of learning
- Learning from instructions (i.e., multidigit addition)
- Learning from experience (i.e., recognizing alphabetical characters)
- Coding/programming refers to learning from instructions
- Machine learning refers to learning from experience
Questions:
What are the different types of learning?
What is an example of learning from instructions and learning from experience, respectively?
What is the difference between coding/programming and machine learning?

Content:
%{content}
Questions:

"

  # The sampling temperature to use (higher values means the engine will take more risks)
  @@question_gen_temperature = 0.2

  # Sourced from https://en.wikipedia.org/wiki/Canada
  @@answer_examples = [
    [
      "What is the world's second-largest country by total area?", 
      "The world's second-largest country by total area is Canada."
    ],
    [
      "What is the capital of Canada?", 
      "Canada's capital is Ottawa."
    ],
    [
      "What are Canada's three largest metropolitan areas?", 
      "Canada's three largest metropolitan areas are Toronto, Montreal, and Vancouver."
    ]
  ]

  # Sourced from https://en.wikipedia.org/wiki/Canada
  @@answer_examples_context = "Canada is a country in North America. Its ten provinces and three territories extend "\
    "from the Atlantic to the Pacific and northward into the Arctic Ocean, covering 9.98 million square kilometres, "\
    "making it the world's second-largest country by total area. Its southern and western border with the United "\
    "States, stretching 8,891 kilometres, is the world's longest bi-national land border. Canada's capital is "\
    "Ottawa, and its three largest metropolitan areas are: Toronto, Montreal, and Vancouver."

  # Maximum is 2048 but due to approximated token length of 4 rounding down to be safe
  @@max_tokens = 1750

  @@min_completion_tokens = 300

  @@answer_stop = ["===", "---", "<|endoftext|>"]
end

module OpenAiApi
  include OpenAiApiParameters

  class OpenAiClient
    include Singleton

    attr_reader :client
    
    def initialize
      @client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:access_token])
    end
  end

  def fetch_question_set content
    prompt = self.generate_prompt content
    completion_tokens = self.calculate_completion_tokens prompt
    self.parse_response :question_set, OpenAiClient.instance.client.completions(
      engine: "davinci-instruct-beta-v3", 
      parameters: {
        prompt: prompt,
        max_tokens: completion_tokens,
        temperature: @@question_gen_temperature
      })
  end
  module_function :fetch_question_set

  def fetch_answer content, question
    content.gsub! ":", ","
    answer_tokens = self.calculate_answer_tokens content, question
    self.parse_response :answer, OpenAiClient.instance.client.answers(parameters: {
      model: "curie",
      question: question,
      examples: @@answer_examples,
      examples_context: @@answer_examples_context,
      documents: [content],
      max_tokens: answer_tokens,
      stop: @@answer_stop
    })
  end
  module_function :fetch_answer

  def self.generate_prompt content
    prompt = @@question_gen_prompt % {content: content}
    prompt_tokens = self.calculate_tokens prompt
    if prompt_tokens >= @@max_tokens - @@min_completion_tokens
      raise Exception.new "Content is too large!"
    end
    prompt
  end
  private_class_method :generate_prompt

  def self.calculate_tokens str
    # Based on fact that a token is approx. 4 characters (https://openai.com/api/pricing/#faq-token)
    (str.length / 4) + 1
  end
  private_class_method :calculate_tokens

  def self.calculate_completion_tokens prompt
    prompt_tokens = self.calculate_tokens prompt
    @@max_tokens - prompt_tokens
  end
  private_class_method :calculate_completion_tokens

  def self.calculate_answer_tokens content, question
    examples_context_tokens = self.calculate_tokens @@answer_examples_context
    examples_tokens = self.calculate_tokens @@answer_examples.map{ |example| example.join("") }.join("")
    question_tokens = self.calculate_tokens question
    @@max_tokens - examples_context_tokens - examples_tokens - question_tokens
  end
  private_class_method :calculate_answer_tokens

  def self.parse_response response_type, response
    if response.code == 200
      self.parse_successful_response response_type, response
    else
      self.handle_erroneous_response response
    end
  end
  private_class_method :parse_response

  def self.parse_successful_response response_type, response
    begin
      case response_type
      when :question_set
        response.parsed_response["choices"].map{ |questions| 
          questions["text"].strip.split("\n").map{ |question| question.slice(question.index(/[a-zA-Z]/)..-1).strip } 
        }.first
      when :answer
        answer_char_limit = 500
        answer = response.parsed_response["answers"].first.strip
        if answer.length > answer_char_limit
          raise Exception.new "Invalid answer created - answer character limit exceeded."
        end
        answer
      else
        raise Exception.new "Invalid response_type passed into OpenAiApi."
      end
    rescue Exception => ex
      raise Exception.new "Unexpected error occured while parsing successful response.\n%{error_info}" % 
        {error_info: ex.inspect}
    end
  end
  private_class_method :parse_successful_response

  def self.handle_erroneous_response response
    begin
      raise Exception.new "%{status_code}: %{error_msg}" % {
        status_code: response.code, 
        error_msg: response.parsed_response["error"]["message"]
      }
    rescue Exception => ex
      raise Exception.new "Unexpected error occured while parsing erroneous response.\n"\
        "Response status code: %{status_code}\n%{error_info}" % {status_code: response.code, error_info: ex.inspect}
    end
  end
  private_class_method :handle_erroneous_response
end
