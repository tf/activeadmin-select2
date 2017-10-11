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

      def scope(current_user)
        case @scope
        when Proc
          @scope.arity.zero? ? @scope.call : @scope.call(current_user)
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

      def as_json(current_user, params)
        results = limit(filter(scope(current_user), params[:term]), params[:limit]).map do |record|
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
