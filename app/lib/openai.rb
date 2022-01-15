require 'singleton'
require 'ruby/openai'

module OpenAiIntegration
    class ClientWrapper
        include Singleton

        attr_reader :client

        def initialize
            @client = OpenAI::Client.new(access_token: Rails.application.secrets.OPENAI_ACCESS_TOKEN)        
        end
    end
    private_constant :ClientWrapper

    @@question_gen_engine = "davinci-instruct-beta-v3"
    @@answer_gen_engine = "davinci-instruct-beta-v3" # TODO
    @@max_tokens = 2048 # maximum allowed

    def fetch_question content
        client_wrapper = ClientWrapper.new
        fetch_question_set client_wrapper.client, content
    end

    def fetch_question_array content_array
        client_wrapper = ClientWrapper.new
        question_sets = Array.new
        content_array.each{ |content| question_sets.append(fetch_question_set client_wrapper.client content) }
    end

    def fetch_question_set client, content
        client.completions(
            engine: @@question_gen_engine, 
            parameters: { 
                prompt: content, 
                max_tokens: @@max_tokens
            })
    end
    private_class_method :fetch_question_set
end