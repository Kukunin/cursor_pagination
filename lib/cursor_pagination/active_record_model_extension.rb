require 'cursor_pagination/page_scope_methods'

module CursorPagination
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      scope :cursor, Proc.new { |cursor, options|
        options = { column: :id, reverse: false }.merge(options || {})

        scope = self
        scope = scope.where("#{options[:column]} #{options[:reverse] ? '<' : '>'} ?", cursor) if cursor
        scope.limit(25)
      } do
        include CursorPagination::PageScopeMethods
      end
    end
  end
end
