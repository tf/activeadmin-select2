module ActiveAdmin
  module Select2
    module SelectInputExtension
      def extra_input_html_options
        {
          class: 'select2-input',
          'data-ajax-url' => ajax_url
        }
      end

      def collection_from_options
        options[:ajax] ? selected_value_collection : super
      end

      private

      def ajax_url
        return unless options[:ajax]
        template.polymorphic_path([:admin, ajax_resource_class],
                                  action: option_collection.collection_action_name)
      end

      def selected_value_collection
        [selected_value_option].compact
      end

      def selected_value_option
        if selected_record
          [option_collection.text(selected_record), selected_record.id]
        end
      end

      def selected_record
        @selected_record ||=
          selected_value && option_collection_scope.find_by_id(selected_value)
      end

      def selected_value
        @object.send(input_name) if @object
      end

      def option_collection_scope
        option_collection.scope(template.current_active_admin_user)
      end

      def option_collection
        ajax_resource
          .select2_option_collections
          .fetch(ajax_options_collection_name) do
          fail()
        end
      end

      def ajax_resource
        template.active_admin_namespace.resource_for(ajax_resource_class)
      end

      def ajax_resource_class
        options[:ajax] == true ? klass : options[:ajax].fetch(:resource)
      end

      def ajax_options_collection_name
        options[:ajax] == true ? :all : options[:ajax].fetch(:name)
      end
    end
  end
end
