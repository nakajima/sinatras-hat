module Sinatra
  module Hat
    class Request
      attr_accessor :result
      attr_writer :success
      attr_reader :request, :action, :model
      
      def self.cache_header_definitions
        @cache_headers ||= {
          :index => {
            :last_modified => proc { |model, params|
              if record = model.klass.first(:order => 'updated_at DESC')
                record.updated_at
              end
            }
          },
          
          :show => {
            :last_modified => proc { |model, params|
              if record = model.find(params)
                record.updated_at
              end
            }
          }
        }
      end
      
      def initialize(request, action)
        @request, @action = request, action
      end
      
      def perform!
        instance_exec(request, &Maker.actions[action][:fn])
        request.not_found if result.nil?
      end
      
      def success
        @success ||= true
      end
      
      alias_method :success?, :success
      
      def set_last_modified(model)
        @model = model
        return unless cache_headers
        request.last_modified cache_headers[:last_modified][model, request.params]
      end
      
      def cache_headers
        Request.cache_header_definitions[action]
      end
      
      def set(key, value)
        send("#{key}=", value)
      end
    end
  end
end