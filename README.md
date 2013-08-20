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

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
