module Sinatra
  module Hat
    # A wrapper around the model class that we're mounting
    class Model
      attr_reader :maker
      
      delegate :options, :klass, :prefix, :to => :maker
      
      def initialize(maker)
        @maker = maker
      end
      
      # Loads all records using the maker's :finder option.
      def all(params)
        params.make_indifferent!
        options[:finder].call(proxy(params), params)
      end
      
      # Loads one record using the maker's :record option.
      def find(params)
        params.make_indifferent!
        options[:record].call(proxy(params), params)
      end
      
      # Finds the owner record of a nested resource.
      def find_owner(params)
        params = parent_params(params)
        options[:record].call(proxy(params), params)
      end
      
      # Updates a record with the given params.
      def update(params)
        if record = find(params)
          params.nest!
          record.attributes = (params[singular] || { })
          record
        end
      end
      
      # Returns a new instance of the mounted model.
      def new(params={})
        params.nest!
        proxy(params).new(params[singular] || { })
      end
      
      # Returns the pluralized name for the model.
      def plural
        klass.name.snake_case.plural
      end
      
      # Returns the singularized name for the model.
      def singular
        klass.name.snake_case.singular
      end
      
      # Returns the foreign_key to be used for this model.
      def foreign_key
        "#{singular}_id".to_sym
      end
      
      # Returns the last modified record from the array of records
      # passed in. It's thorougly inefficient, since it requires all
      # of the cacheable data to be loaded anyway.
      def find_last_modified(records)
        if records.all? { |r| r.respond_to?(:updated_at) }
          records.sort_by { |r| r.updated_at }.last
        else
          records.last
        end
      end
      
      private
      
      # Returns an association proxy for a nested resource if available,
      # otherwise it just returns the class.
      def proxy(params)
        return klass unless parent
        owner = parent.find_owner(params)
        if owner and owner.respond_to?(plural)
          owner.send(plural)
        else
          klass
        end
      end
      
      # Dups and modifies params so that they can be used to find a parent.
      def parent_params(params)
        _params = params.dup.to_mash
        _params.merge! :id => _params.delete(foreign_key)
        _params
      end
      
      # Returns the parent model if there is one, otherwise nil.
      def parent
        return nil unless maker.parent
        maker.parent.model
      end
    end
  end
end