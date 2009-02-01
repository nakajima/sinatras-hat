module Sinatra
  module Hat
    # A wrapper around the model class that we're mounting
    class Model
      attr_reader :maker
      
      delegate :options, :klass, :prefix, :to => :maker
      
      def initialize(maker)
        @maker = maker
      end
      
      def all(params)
        params.make_indifferent!
        options[:finder].call(proxy(params), params)
      end
      
      def find(params)
        params.make_indifferent!
        options[:record].call(proxy(params), params)
      end
      
      def find_owner(params)
        params = parent_params(params)
        options[:record].call(proxy(params), params)
      end
      
      def update(params)
        if record = find(params)
          params.nest!
          record.attributes = (params[singular] || { })
          record
        end
      end
      
      def new(params={})
        params.nest!
        proxy(params).new(params[singular] || { })
      end
      
      def plural
        klass.name.snake_case.plural
      end
      
      def singular
        klass.name.snake_case.singular
      end
      
      def foreign_key
        "#{singular}_id".to_sym
      end
      
      def find_last_modified(records)
        if records.all? { |r| r.respond_to?(:updated_at) }
          records.sort_by { |r| r.updated_at }.last
        else
          records.last
        end
      end
      
      private
      
      def proxy(params)
        return klass unless parent
        owner = parent.find_owner(params)
        if owner and owner.respond_to?(plural)
          owner.send(plural)
        else
          klass
        end
      end
      
      def parent_params(params)
        _params = params.dup.to_mash
        _params.merge! :id => _params.delete(foreign_key)
        _params
      end
      
      def parent
        return nil unless maker.parent
        maker.parent.model
      end
    end
  end
end