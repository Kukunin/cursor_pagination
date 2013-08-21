require 'cursor_pagination/page_scope_methods'

module CursorPagination
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      scope :cursor, Proc.new { |*arg|
        (if arg.last.blank?
          where('1=1') #dirty hack to emulated empty scope
        else
          where(*arg)
        end).limit(25)
      } do
        include CursorPagination::PageScopeMethods
      end
    end
  end
end
