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
    - code related
        - test question gen util functions
        - figure out openai response object and build in error handling

- answer gen
    - open ai related
        - create answer gen prompt
        - tweak params
    - code related
        - create util functions for answer gen
        - test question gen util functions
        - figure out openai response object and build in error handling

=end

module OpenAiApi
    class OpenAiClient
        include Singleton

        attr_reader :client

        def initialize
            @client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:access_token])
        end
    end

    @@question_gen_prompt = "
Create a list of questions based on the content

Content:
Technology is the system/tool we used to solve problems. Education is one of the greatest technologies ever created (students are the product of this technological system). Government is another form of technology. Both the above are considered invisible technologies (systems that do not necessarily produce physical objects).
Questions:
1. What is technology?
2. What could be considered one of the greatest technologies ever created?
3. What is the class of technologies that does not produce physical objects?

Content:
Herbert Butterfield 
- Argued that external factors have no impact on progress of science and technology (all internal) 
- Argued that what we should study is what scientists do internally within science (he was a physicist so he focused specifically on that field) 
- Was a prominent way of looking at science and our relationship with it for a long time but not anymore 
Questions:
1. Did Herbert Butterfield believe that external factors had an impact on science and technology?
2. Is the belief that scientific and technological progress is not impacted by external factors prominent now?

Content:
Machine 
- Computer
- Turing machine (anything computed by a non-biological computer can be computed by a Turing machine)
- Automates processes
Questions:
1. What is a Turing machine?
2. What is a main function of machines?
3. Is a computer an example of a machine?

Content:
Learning
-	More than one type of learning
-	Learning from instructions (i.e., multidigit addition)
-	Learning from experience (i.e., recognizing alphabetical characters)
-	Coding/programming refers to learning from instructions
-	Machine learning refers to learning from experience
Questions:
1. What are the different types of learning?
2. What is an example of learning from instructions and learning from experience, respectively?
3. What is the difference between coding/programming and machine learning?

Content:
%{content}
Questions:
"
    @@answer_gen_prompt = ""
    @@max_tokens = 2048
    @@min_completion_tokens = 300

    def fetch_question_set_array content_array
        content_array.each{ |content| question_sets.append(self.fetch_question_set content) }
    end
    module_function :fetch_question_set_array

    def fetch_question_set content
        prompt = self.generate_prompt true, content
        completion_tokens = self.calculate_completion_tokens prompt
        self.parse_response(OpenAiClient.instance.client.completions(
            engine: "davinci-instruct-beta-v3", 
            parameters: {
                prompt: prompt, 
                max_tokens: completion_tokens
            }))
    end
    module_function :fetch_question_set

    def self.generate_prompt is_question_gen, content
        # TODO answer gen
        prompt = is_question_gen ? @@question_gen_prompt % {content: content} : @@answer_gen_prompt
        prompt_tokens = self.calculate_prompt_tokens prompt
        if prompt_tokens >= @@max_tokens - @@min_completion_tokens
            raise Exception.new "Content is too large!"
        end
        prompt
    end
    private_class_method :generate_prompt

    def self.calculate_prompt_tokens prompt
        # Based on fact that a token is approx. 4 characters (https://openai.com/api/pricing/#faq-token)
        (prompt.length / 4) + 1
    end
    private_class_method :calculate_prompt_tokens

    def self.calculate_completion_tokens prompt
        prompt_tokens = self.calculate_prompt_tokens prompt
        @@max_tokens - prompt_tokens
    end
    private_class_method :calculate_completion_tokens

    def self.parse_response response
        if response.code == 200
            begin
                response.parsed_response["choices"].map{ |questions| questions["text"].split("\n") }.first
            rescue Exception => ex
                raise Exception.new "Unexpected error occured while parsing successful response.\n%{error_info}" % 
                    {error_info: ex.inspect}
            end
        else
            begin
                raise Exception.new "%{status_code}: %{error_msg}" % {
                    status_code: response.code, 
                    error_msg: response.parsed_response["error"]["message"]
                }
            rescue Exception => ex
                raise Exception.new "Unexpected error occured while parsing erroneous response.\n%{error_info}" % 
                    {error_info: ex.inspect}
            end
        end

    end
    private_class_method :parse_response
end