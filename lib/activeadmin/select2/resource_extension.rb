module ActiveAdmin
  module Select2
    module ResourceExtension
      def select2_option_collections
        @select2_option_collections ||= {}
      end
    end
  end
end
