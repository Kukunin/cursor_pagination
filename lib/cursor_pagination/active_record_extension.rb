require 'active_support/concern'
require 'cursor_pagination/active_record_model_extension'

module CursorPagination
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    included do
      # Future subclasses will pick up the model extension
      class << self
        def inherited_with_cursor_pagination(kls) #:nodoc:
          inherited_without_cursor_pagination kls
          kls.send(:include, CursorPagination::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
        end
        alias_method :inherited_without_cursor_pagination, :inherited
        alias_method :inherited, :inherited_with_cursor_pagination
      end

      # Existing subclasses pick up the model extension as well
      self.descendants.each do |kls|
        kls.send(:include, CursorPagination::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
      end
    end
  end
end
