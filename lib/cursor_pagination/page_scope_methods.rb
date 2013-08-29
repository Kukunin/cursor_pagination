module CursorPagination
  module PageScopeMethods
    def per(num)
      limit(num)
    end

    def first_page?
      previous_cursor.value == -1
    end

    def last_page?
      next_cursor.value == -1
    end

    def previous_cursor
      Cursor.new(if current_cursor.empty?
        -1
      else
        options = cursor_options

        scope = _origin_scope.where("#{options[:column]} #{options[:reverse] ? '>' : '<'}= ?", current_cursor.value).limit(limit_value+1).reverse_order
        result = scope.to_a

        case result.size
        when limit_value+1
          result.last.send(options[:column])
        when 0
          -1 #no previous page
        else
          nil #first page, incomplete
        end
      end)
    end

    def next_cursor
      Cursor.new(if last.nil?
        -1
      else
        # try to get something after last cursor
        cursor = Cursor.new last.send(cursor_options[:column])
        _origin_scope.cursor(cursor, cursor_options).per(1).count.zero? ? -1 : cursor.value
      end)
    end
  end
end
