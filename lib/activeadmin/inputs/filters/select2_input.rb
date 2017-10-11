module ActiveAdmin
  module Inputs
    module Filters
      class Select2Input < SelectInput
        include Select2::SelectInputExtension

#        def extra_input_html_options
#          data_attributes.merge(class: 'select2-input')
#        end
#
#        def collection_from_options
#          if options[:ajax]
#            []
#          end
#        end
#
#        private
#
#        def data_attributes
#          return {} unless options[:ajax]
#
#          {
#            'data-selected-value' => selected_value,
#            'data-ajax-url' => url
#          }
#        end
#
#        def url
#          url = options[:ajax][:url]
#          url.is_a?(Symbol) ? Rails.application.routes.url_helpers.send(url) : url
#        end
#
#        def selected_value
#          @object.send(input_name) if @object
#        end
      end
    end
  end
end
