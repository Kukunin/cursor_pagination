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
        cursor = Cursor.decode(cursor) unless cursor.is_a? Cursor

        options.reverse_merge! column: :id, reverse: false, columns: {}
        if options[:columns].empty?
          options[:columns][options[:column]] = { reverse: options[:reverse] }
        end

        scoped_method = ActiveRecord::VERSION::STRING < '4.0' ? :scoped : :all
        @current_cursor = cursor
        @origin_scope = self.send scoped_method
        @cursor_options = options

        scope = @origin_scope
        unless cursor.empty?
          cursor_value = [*cursor.value]
          scope = scope.where _cursor_to_where(options[:columns], cursor_value)
        end
        scope = scope.limit(25)

        scope.extending(CursorPagination::PageScopeMethods)
      end

      private
      def self._cursor_to_where(columns, cursor, reverse = false)
        _cursor_to_where_recursion(0, arel_table, columns.to_a, cursor, reverse)
      end

      def self._cursor_to_where_recursion(i, t, columns, cursor, reverse = false)
        column = columns[i]
        method = column.last[:reverse] ? :lt : :gt
        method = (method == :lt ? :gt : :lt) if reverse
        if (columns.size - i) == 1 #last column
          method = (method == :lt ? :lteq : :gteq) if reverse
          t[column.first].send method, cursor[i]
        else
          t[column.first].send(method, cursor[i]).or(t[column.first].eq(cursor[i]).and(_cursor_to_where_recursion(i+1, t, columns, cursor, reverse)))
        end
      end

    end
  end
end
