require "cursor_pagination/version"
require "cursor_pagination/active_record_extension"

module CursorPagination
  ::ActiveRecord::Base.send(:include, CursorPagination::ActiveRecordExtension)
end
