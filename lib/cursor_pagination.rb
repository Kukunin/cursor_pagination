require "cursor_pagination/version"
require "cursor_pagination/active_record_extension"
require 'cursor_pagination/action_view_helper'

module CursorPagination
  ::ActiveRecord::Base.send(:include, CursorPagination::ActiveRecordExtension)
end
