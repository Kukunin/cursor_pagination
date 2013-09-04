module CursorPagination
  module PageScopeMethods
    def current_cursor
      @current_cursor
    end

    def current_cursor=(cursor)
      @current_cursor = cursor
    end

    def _origin_scope
      @origin_scope
    end

    def _origin_scope=(scope)
      @origin_scope = scope
    end

    def cursor_options
      @cursor_options
    end

    def cursor_options=(options)
      @cursor_options = options
    end

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
        scope = _origin_scope.limit(limit_value+1).reverse_order
        columns = cursor_options[:columns]

        cursor_value = [*current_cursor.value]
        scope = scope.where _cursor_to_where(columns, cursor_value, true)
        result = scope.to_a

        case result.size
        when limit_value+1
          Cursor.value_from_entity result.last, columns
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
        cursor = Cursor.from_entity last, cursor_options[:columns]
        _origin_scope.cursor(cursor, cursor_options).per(1).count.zero? ? -1 : cursor.value
      end)
    end
  end
end
