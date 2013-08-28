# CursorPagination

ActiveRecord plugin for cursor based pagination. It uses specific model's column and rpp (results per page) to paginate your content.

The main advantage against traditional pagination (limmit and offset), that the one URL on specific page will contain the data set, despite the newly added entities. It may be useful on the projects, where new entities are added often, and specific page now isn't specific page tomorrow.

## Installation

Add this line to your application's Gemfile:

    gem 'cursor_pagination'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cursor_pagination

## Usage

Just use `cursor` scope on your model chain:

    User.where(active: true).cursor(params[:cursor]).per(20)

It will get 20 users by passed cursor. You can omit `per` scope:

    User.where(active: true).cursor(params[:cursor])

In this case, the limit of entities per page will be 25 by default.

You can pass options as second argument for `cursor` scope

    User.order('id DESC').cursor(params[:cursor], reverse: true).per(20)

## How it works?

Actually, cursor is column value of specific entity, it uses to get all entities, later than specific. For example, if you have the Users set with IDs from 1 to 5,

    User.cursor(2).per(20)

will return maximum 20 users after ID 2 (in this case, users with IDs 3, 4 and 5).

**Make sure that your objects are ordered by cursored column. If you use DESC order, use `reverse: true` option in `cursor` scope.**

## Options

At this point, `cursor` scope accepts these options:

* `reverse`: Set it to true, if your set are ordered descendingly (_DESC_). Default: _false_
* `column`: column value of cursor. For example, if you order your data set by *updated_at*, set *updated_at* column for cursor. Default: _id_

## Scope methods

* `first_page?/last_page?` - **true/false**

```
@users = User.cursor(params[:cursor]).per(20)
@users.first_page?
```

* `next_cursor/previous_cursor` - **cursor, nil or -1**. Returns the column value for cursor of next/previous page.
  _nil_ is valid cursor too. It means first page. If cursor is unavailable (there isn't pages anymore), returns _-1_.

## Helpers

* `next_cursor_url/previous_cursor_url` - **string**

```
next_cursor_url(scope, url_options = {})
previous_cursor_url(scope, url_options = {})
```

  Returns the URL for next/previous cursor page or nil, if there isn't next/previous cursor available.

```
<%= next_cursor_url(@users)     %> # users/?cursor=3
<%= previous_cursor_url(@users) %> # users/?cursor=1
```

* `next_cursor_link/previous_cursor_link` - **string**

```
next_cursor_link(scope, name, url_options = {}, html_options = {})
previous_cursor_link(scope, name, url_options = {}, html_options = {})
```

  Returns the A html element with URL on next/previous cursor or nil, if there isn't next/previous cursor available. Accepts the same arguments, as `link_to` helper method, but scope object as first argument.

```
# <a href="users/?cursor=3" rel="next">Next Page</a>
<%= next_cursor_link(scope, 'Next Page') %>
# <a href="users/?cursor=1" rel="previous">Previous Page</a>
<%= previous_cursor_link(scope, 'Previous Page') %>
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
