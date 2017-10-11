# -*- coding: utf-8 -*-
module ActiveAdmin
  module Select2
    class OptionCollection
      def initialize(name, scope:, text_attribute:)
        @name = name
        @scope = scope
        @text_attribute = text_attribute
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
