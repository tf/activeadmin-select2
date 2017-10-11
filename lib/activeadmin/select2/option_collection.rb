module ActiveAdmin
  module Select2
    class OptionCollection
      def initialize(name, options)
        @name = name

        @scope = options.fetch(:scope) do
          raise('Missing option: scope. ' \
                'Pass the collection of items to render options for.')
        end

        @text_attribute = options.fetch(:text_attribute) do
          raise('Missing option: text_attribute. ' \
                'Pass the name of a method which returns a display name.')
        end
      end

      def scope(template, params)
        case @scope
        when Proc
          if @scope.arity.zero?
            template.instance_exec(&@scope)
          else
            template.instance_exec(params, &@scope)
          end
        else
          @scope
        end
      end

      def text(record)
        record.send(@text_attribute)
      end

      def collection_action_name
        "#{@name}_options"
      end

      def as_json(template, params)
        results = limit(filter(scope(template, params), params[:term]), params[:limit]).map do |record|
          {
            id: record.id,
            text: text(record)
          }
        end

        { results: results }
      end

      private

      def filter(scope, term)
        term ? scope.ransack("#{@text_attribute}_cont" => term).result : scope
      end

      def limit(scope, count)
        scope.limit(count || 10)
      end
    end
  end
end
