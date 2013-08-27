require 'cursor_pagination/page_scope_methods'

module CursorPagination
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      def self.current_cursor
        @current_cursor
      end

      def self._origin_scope
        @origin_scope
      end

      def self.cursor_options
        @cursor_options
      end

      scope :cursor, Proc.new { |cursor, options|
        options = { column: :id, reverse: false }.merge(options || {})
        @current_cursor = cursor
        @origin_scope = self.all
        @cursor_options = options

        scope = @origin_scope
        scope = scope.where("#{options[:column]} #{options[:reverse] ? '<' : '>'} ?", cursor) if cursor
        scope.limit(25)
      } do
        include CursorPagination::PageScopeMethods
      end
    end
  end
end
