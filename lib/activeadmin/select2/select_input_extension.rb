module ActiveAdmin
  module Select2
    module SelectInputExtension
      def extra_input_html_options
        super.merge(class: 'select2-input',
                    'data-ajax-url' => ajax_url)
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
        [option_collection.text(selected_record), selected_record.id] if selected_record
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
          raise("No option collection named '#{ajax_options_collection_name}' " \
                "defined in '#{ajax_resource_class.name}' admin.")
        end
      end

      def ajax_resource
        @ajax_resource ||=
          template.active_admin_namespace.resource_for(ajax_resource_class) ||
          raise("No admin found for '#{ajax_resource_class.name}' to fetch " \
                'options for select2 from.')
      end

      def ajax_resource_class
        ajax_options.fetch(:resource) do
          unless reflection
            raise('Cannot auto detect resource to fetch options for select2 input from. ' \
                  "Explicitly pass class of an ActiveAdmin resource:\n\n" \
                  "  f.input(:custom_category,\n" \
                  "          type: :select2,\n" \
                  "          ajax: {\n" \
                  "            resource: Category\n" \
                  "          })\n")
          end

          reflection.klass
        end
      end

      def ajax_options_collection_name
        ajax_options.fetch(:collection_name, :all)
      end

      def ajax_options
        options[:ajax] == true ? {} : options[:ajax]
      end
    end
  end
end
