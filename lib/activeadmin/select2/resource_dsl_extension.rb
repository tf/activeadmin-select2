module ActiveAdmin
  module Select2
    module ResourceDSLExtension
      def select2_options(name: :all, **options)
        option_collection = OptionCollection.new(name, options)
        config.select2_option_collections[name] = option_collection

        collection_action(option_collection.collection_action_name) do
          render(json: option_collection.as_json(current_user, params))
        end
      end
    end
  end
end
