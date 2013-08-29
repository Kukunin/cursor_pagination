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
      return -1 if current_cursor.nil?
      options = cursor_options
      scope = _origin_scope.where("#{options[:column]} #{options[:reverse] ? '>' : '<'}= ?", decode_cursor(current_cursor)).limit(limit_value+1)

      result = scope.to_a

      case result.size
      when limit_value+1
        encode_cursor result.first.send(options[:column])
      when 0
        -1 #no previous page
      else
        nil #first page, incomplete
      end

    end

    def next_cursor
      return -1 if last.nil?
      # try to get something after last cursor
      cursor = encode_cursor last.send(cursor_options[:column])
      _origin_scope.cursor(cursor, cursor_options).per(1).count.zero? ? -1 : cursor
    end
  end
end
