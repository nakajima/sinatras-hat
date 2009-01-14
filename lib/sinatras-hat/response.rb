module Sinatra
  class NoTemplateError < StandardError; end
  
  module Hat
    # Tells Sinatra what to do next.
    class Response
      attr_reader :maker
      
      delegate :resource_path, :to => :maker
      
      def initialize(maker, request)
        @maker = maker
        @request = request
      end
      
      def render(action)
        begin
          @request.erb action.to_sym, :views_directory => views
        rescue Errno::ENOENT
          no_template! "Can't find #{File.expand_path(File.join(views, action.to_s))}.erb"
        end
      end
      
      def redirect(resource)
        @request.redirect url_for(resource)
      end
      
      private
      
      def no_template!(msg)
        raise NoTemplateError.new(msg)
      end
      
      def views
        @views ||= begin
          if views_dir = @request.options.views
            File.join(views_dir, maker.prefix)
          else
            no_template! "Make sure you set the :views option!"
          end
        end
      end
      
      def url_for(resource)
        case resource
        when String then resource
        else resource_path('/:id', resource)
        end
      end
    end
  end
end