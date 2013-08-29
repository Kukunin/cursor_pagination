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

      def self.encode_cursor(cursor)
        if cursor_column_type == :datetime and cursor.is_a? Time
          cursor = cursor.to_yaml
        end
        cursor
      end

      def self.decode_cursor(cursor)
        if cursor_column_type == :datetime and cursor.is_a? String
          cursor = YAML.load(cursor)
        end
        cursor
      end

      def self.cursor_column_type
        columns_hash[cursor_options[:column].to_s].type
      end

      def self.cursor(cursor, options = {})
        options.reverse_merge! column: :id, reverse: false
        scoped_method = ActiveRecord::VERSION::STRING < '4.0' ? :scoped : :all
        @current_cursor = cursor
        @origin_scope = self.send scoped_method
        @cursor_options = options

        scope = @origin_scope
        if cursor and cursor != -1
          decoded_cursor = decode_cursor cursor
          scope = scope.where("#{options[:column]} #{options[:reverse] ? '<' : '>'} ?", decoded_cursor)

        end

        scope = scope.limit(25)
        scope.extending(CursorPagination::PageScopeMethods)
      end
    end
  end
end
