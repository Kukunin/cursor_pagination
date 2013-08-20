require 'spec_helper'

describe CursorPagination do

  it "returns VERSION" do
    CursorPagination::VERSION.should_not be_nil
  end

end
