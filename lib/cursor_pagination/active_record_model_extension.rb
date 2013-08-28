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

      def self.cursor(cursor, options = {})
        options.reverse_merge! column: :id, reverse: false
        scoped_method = ActiveRecord::VERSION::STRING < '4.0' ? :scoped : :all
        @current_cursor = cursor
        @origin_scope = self.send scoped_method
        @cursor_options = options

        scope = @origin_scope
        scope = scope.where("#{options[:column]} #{options[:reverse] ? '<' : '>'} ?", cursor) if cursor
        scope = scope.limit(25)

        scope.extending(CursorPagination::PageScopeMethods)
      end
    end
  end
end
