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
What is technology?
What could be considered one of the greatest technologies ever created?
What is the class of technologies that does not produce physical objects?

Content:
Herbert Butterfield 
- Argued that external factors have no impact on progress of science and technology (all internal) 
- Argued that what we should study is what scientists do internally within science (he was a physicist so he focused specifically on that field) 
- Was a prominent way of looking at science and our relationship with it for a long time but not anymore 
Questions:
Did Herbert Butterfield believe that external factors had an impact on science and technology?
Is the belief that scientific and technological progress is not impacted by external factors prominent now?

Content:
Machine 
- Computer
- Turing machine (anything computed by a non-biological computer can be computed by a Turing machine)
- Automates processes
Questions:
What is a Turing machine?
What is a main function of machines?
Is a computer an example of a machine?

Content:
Learning
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

  # Sourced from https://en.wikipedia.org/wiki/Fall_of_the_Western_Roman_Empire#:~:text=The%20fall%20of%20the%20Western,divided%20into%20several%20successor%20polities.
  @@answer_examples = [
    [
      "What caused the fall of the Western Roman Empire?", 
      "The fall of the Western Roman Empire was due to a loss of effective control over its Western provinces."
    ],
    [
      "What were some of the immediate factors that contributed to the collapse?", 
      "Some of the immediate factors that contributed to the collapse include a smaller and less effective army, "\
      "the health and size of the Roman population, the strength of the economy, the competence of the emporers, "\
      "the internal struggles for power, and changes in religious beliefs. External pressures from invading "\
      "barbarians, climatic changes, and epidemic disease exaggerated many of these immediate factors."
    ],
    [
      "What are some of the major subjects of the historiography of the ancient world?", 
      "The reasons for the collapse of the Western Roman Empire."
    ]
  ]

  @@answer_examples_context = "The fall of the Western Roman Empire was the loss of central political control in "\
    "the Western Roman Empire, a process in which the Empire failed to enforce its rule, and its vast territory was "\
    "divided into several successor polities. The Roman Empire lost the strengths that had allowed it to exercise "\
    "effective control over its Western provinces; modern historians posit factors including the effectiveness and "\
    "numbers of the army, the health and numbers of the Roman population, the strength of the economy, the "\
    "competence of the emperors, the internal struggles for power, the religious changes of the period, and the "\
    "efficiency of the civil administration. Increasing pressure from invading barbarians outside Roman culture also "\
    "contributed greatly to the collapse. Climatic changes and epidemic disease drove many of these immediate "\
    "factors. The reasons for the collapse are major subjects of the historiography of the ancient world and they "\
    "inform much modern discourse on state failure."

  # Maximum is 2048 but due to approximated token length of 4 rounding down to be safe
  @@max_tokens = 1900
  
  @@num_questions = 1

  @@min_completion_tokens = 300

  @@answer_stop = ["\n", "<|endoftext|>"]
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
        n: @@num_questions
      })
  end
  module_function :fetch_question_set

  def fetch_answer content, question
    content.gsub! "\n", " "
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
          questions["text"].strip.split("\n").map{ |question| question.strip } 
        }.first
      when :answer
        response.parsed_response["answers"].first.strip
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
