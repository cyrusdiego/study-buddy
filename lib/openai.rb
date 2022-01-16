require 'singleton'
require 'ruby/openai'

=begin

TODOs

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
    class ClientWrapper
        include Singleton

        attr_reader :client

        def initialize
            @client = OpenAI::Client.new(access_token: Rails.application.secrets.OPENAI_ACCESS_TOKEN)        
        end
    end
    # private_constant :ClientWrapper

    def fetch_question content
        client_wrapper = ClientWrapper.new
        fetch_question_set client_wrapper.client, content
    end
    module_function :fetch_question

    def fetch_question_array content_array
        client_wrapper = ClientWrapper.new
        question_sets = Array.new
        content_array.each{ |content| question_sets.append(fetch_question_set client_wrapper.client content) }
    end
    module_function :fetch_question_array

    def fetch_question_set client, content
        question_gen_prompt = %Q{
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
            #{content}
            Questions:
            1. 
        }
        client.completions(
            engine: "davinci-instruct-beta-v3", 
            parameters: { 
                prompt: question_gen_prompt, 
                max_tokens: 2048 # max allowed
            })
    end
    private_class_method :fetch_question_set
end