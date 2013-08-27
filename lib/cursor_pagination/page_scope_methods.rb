module CursorPagination
  module PageScopeMethods
    def per(num)
      limit(num)
    end

    def first_page?
      previous_cursor == -1
    end

    def last_page?
      next_cursor == -1
    end

    def previous_cursor
      options = cursor_options
      result = _origin_scope.where("#{options[:column]} #{options[:reverse] ? '>' : '<'}= ?", current_cursor).limit(limit_value+1).to_a
      case result.size
      when limit_value+1
        result.first.send(options[:column])
      when 0
        -1 #no previous page
      else
        nil #first page, incomplete
      end

    end

    def next_cursor
      return -1 if last.nil?
      # try to get something after last cursor
      cursor = last.send(cursor_options[:column])
      _origin_scope.cursor(cursor, cursor_options).per(1).count.zero? ? -1 : cursor
    end
  end
end
