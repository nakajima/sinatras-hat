module Sinatra
  module Hat
    module ChildActions
      def generate_child_actions!
        children.each do |resource|
          mount(resource)
        end
      end
    end
  end
end