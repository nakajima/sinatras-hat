module Sinatra
  class NoTemplateError < StandardError; end
  
  module Hat
    # Tells Sinatra what to do next.
    class Response
      attr_reader :maker
      
      delegate :model, :resource_path, :to => :maker
      
      def initialize(maker, request)
        @maker = maker
        @request = request
      end
      
      def render(action, options={})
        begin
          options.each { |sym, value| @request.send(sym, value) }
          @request.erb "#{maker.prefix}/#{action}".to_sym
        rescue Errno::ENOENT
          no_template! "Can't find #{File.expand_path(File.join(views, action.to_s))}.erb"
        end
      end
      
      def redirect(*args)
        @request.redirect url_for(*args)
      end
      
      def url_for(resource, *args)
        case resource
        when String then resource
        when Symbol then resource_path(Maker.actions[resource][:path], *args)
        else maker_for(resource).resource_path('/:id', resource)
        end
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
      
      def maker_for(record)
        resource = record.is_a?(model.klass) ? maker : maker.parents.detect { |m| record.is_a?(m.model.klass) }
        resource || maker
      end
    end
  end
end