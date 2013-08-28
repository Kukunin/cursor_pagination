module CursorPagination
  module ActionViewHelper
    def next_cursor_link(scope, name, params = {}, options = {}, &block)
      url = next_cursor_url(scope, params)
      link_to_unless url.nil?, name, url, options.reverse_merge(:rel => 'next') do
        block.call if block
      end
    end

    def next_cursor_url(scope, params = {})
      url_for(params.merge(cursor: scope.next_cursor)) unless scope.last_page?
    end

    def previous_cursor_link(scope, name, params = {}, options = {}, &block)
      url = previous_cursor_url(scope, params)
      link_to_unless url.nil?, name, url, options.reverse_merge(:rel => 'previous') do
        block.call if block
      end
    end

    def previous_cursor_url(scope, params = {})
      url_for(params.merge(cursor: scope.previous_cursor)) unless scope.first_page?
    end
  end
end
