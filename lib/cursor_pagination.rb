require 'action_view'

require "cursor_pagination/version"

module CursorPagination

  class Cursor
    attr_reader :cursor

    def initialize(cursor)
      @cursor = cursor
    end

    def self.decode(cursor)
      unless cursor.nil?
        new YAML.load(Base64.strict_decode64(cursor))
      else
        new nil
      end
    end

    def self.value_from_entity(entity, columns)
      value = []
      columns.each_key do |column|
        value << entity.send(column)
      end
      value.size == 1 ? value.first : value
    end

    def self.from_entity(entity, columns)
      new value_from_entity(entity, columns)
    end

    def encoded
      Base64.strict_encode64 cursor.to_yaml
    end

    def empty?
      cursor.nil? || invalid?
    end

    def invalid?
      cursor == -1
    end

    def value
      @cursor
    end

    def to_s
      cursor.nil? ? nil : encoded
    end
  end
end

#Include ActiveRecord extension
require "cursor_pagination/active_record_extension"
::ActiveRecord::Base.send :include, CursorPagination::ActiveRecordExtension

#Include ActionView Helper
require 'cursor_pagination/action_view_helper'
ActiveSupport.on_load(:action_view) do
  ::ActionView::Base.send :include, ::CursorPagination::ActionViewHelper
end
