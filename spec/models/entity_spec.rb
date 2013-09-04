require 'spec_helper'

describe Entity do

  include_context "entities"

  specify do
    first_entity.id.should be < second_entity.id
    first_entity.custom.should be > second_entity.custom
  end

  describe "cursor-specific options" do
    let(:first_options) do
      { column: :custom, reverse: false }
    end
    let(:second_options) do
      { column: :id, reverse: true }
    end

    it "doesn't overlap each other" do
      first_scope = Entity.cursor(nil, first_options)
      second_scope = Entity.cursor(nil, second_options)

      first_scope.per(10).cursor_options.should eq first_options
      second_scope.cursor_options.should eq second_options
    end
  end

  describe "cursor_options" do
    it "accepts default values" do
      options = Entity.cursor(nil).cursor_options
      options[:columns].should eq id: { reverse: false }
    end

    it "accepts short column notation" do
      options = Entity.cursor(nil, column: :custom, reverse: true).cursor_options
      options[:columns].should eq custom: { reverse: true }
    end

    it "prefer full columns notation" do
      full_options = { custom: { reverse: false } }
      options = Entity.cursor(nil, column: :custom_time, reverse: true, columns: full_options).cursor_options
      options[:columns].should eq full_options
    end
  end

  describe "#cursor method" do
    it "returns first entity only" do
      result = first_page.to_a
      result.size.should eq 1
      result.first.should eq first_entity
    end

    it "returns second entity only" do
      result = second_page.to_a
      result.size.should eq 1
      result.first.should eq second_entity
    end

    it "support different orders" do
      result = Entity.order('id DESC').cursor(c(second_entity.id), reverse: true).per(1).to_a
      result.size.should eq 1
      result.first.should eq first_entity
    end

    it "support different columns" do
      result = Entity.cursor(c(second_entity.id), column: :custom).per(1).to_a
      result.size.should eq 1
      result.first.should eq first_entity
    end

    describe "time columns" do
      let(:columns) do
        { custom_time: { reverse: false }, id: { reverse: false } }
      end
      let(:scope) { Entity.order('custom_time ASC, id ASC') }
      let(:first_page) { scope.cursor(nil, columns: columns ).per(1) }
      specify { first_page.next_cursor.value.should eq [last_entity.custom_time, last_entity.id] }
      let(:second_page) { scope.cursor(first_page.next_cursor, columns: columns).per(1) }
      specify { second_page.next_cursor.value.should eq [third_entity.custom_time, third_entity.id] }
      let(:previous_page) { scope.cursor(second_page.previous_cursor, columns: columns).per(1) }
      specify { previous_page.next_cursor.value.should eq [last_entity.custom_time, last_entity.id] }
      let(:third_page) { scope.cursor(second_page.next_cursor, columns: columns).per(1) }
      specify { third_page.next_cursor.value.should eq [second_entity.custom_time, second_entity.id] }

      specify { first_page.first.should eq last_entity }
      specify { second_page.first.should eq third_entity }
      specify { third_page.first.should eq second_entity }
      specify { previous_page.first.should eq last_entity }
    end

    context "without #per method" do
      before do
        25.times { Entity.create! }
      end

      it "returns all Entities" do
        result = Entity.cursor(nil).to_a
        result.size.should eq 25
      end
    end
  end

  describe "cursor methods" do
    # nil is valid cursor too, it means first page
    # -1 means unavailable cursor (last or first page)
    describe "#next_cursor" do
      ##Default settings
      specify { Entity.cursor(nil).per(10).next_cursor.value.should eq -1 }
      specify { Entity.cursor(nil).per(10).should be_last_page }
      specify { first_page.next_cursor.should be_a CursorPagination::Cursor }
      specify { first_page.next_cursor.value.should eq first_entity.id}
      specify { first_page.should_not be_last_page}
      specify { last_page.next_cursor.value.should eq -1 }

      ##Reverse order
      specify { Entity.order('id DESC').cursor(nil, reverse: true).per(1).next_cursor.value.should eq last_entity.id }
      specify { Entity.order('id DESC').cursor(c(second_entity.id), reverse: true).per(1).next_cursor.value.should eq -1 }

      ##With custom column
      specify { Entity.order('custom ASC').cursor(c(second_entity.custom), column: :custom).per(1).next_cursor.value.should eq -1 }
      specify { Entity.order('custom ASC').cursor(c(third_entity.custom), column: :custom).per(1).next_cursor.value.should eq second_entity.custom }
      specify { Entity.order('custom ASC').cursor(nil, column: :custom).per(1).next_cursor.value.should eq last_entity.custom }
    end

    describe "#previous_cursor" do
      ##Default settings
      #no previous page
      specify { Entity.cursor(nil).previous_cursor.value.should eq -1 }
      specify { Entity.cursor(nil).should be_first_page }
      #not full previous page
      specify { Entity.cursor(c(first_entity.id)).previous_cursor.value.should be_nil }
      specify { Entity.cursor(c(first_entity.id)).should_not be_first_page }
      #full previous page
      specify { third_page.previous_cursor.value.should eq first_entity.id }
      specify { third_page.should_not be_first_page }

      ##Reverse order
      specify { Entity.order('id DESC').cursor(nil, reverse: true).previous_cursor.value.should eq -1 }
      specify { Entity.order('id DESC').cursor(c(last_entity.id), reverse: true).previous_cursor.value.should be_nil }
      specify { Entity.order('id DESC').cursor(c(third_entity.id), reverse: true).per(1).previous_cursor.value.should eq last_entity.id }

      ##With custom column
      specify { Entity.order('custom ASC').cursor(nil, column: :custom).previous_cursor.value.should eq -1 }
      specify { Entity.order('custom ASC').cursor(c(last_entity.custom), column: :custom).previous_cursor.value.should be_nil }
      specify { Entity.order('custom ASC').cursor(c(third_entity.custom), column: :custom).per(1).previous_cursor.value.should eq last_entity.custom }
      specify { Entity.order('custom ASC').cursor(c(second_entity.custom), column: :custom).per(1).previous_cursor.value.should eq third_entity.custom }
      specify { Entity.order('custom ASC').cursor(c(first_entity.custom), column: :custom).per(1).previous_cursor.value.should eq second_entity.custom }
    end
  end

  describe "._cursor_to_where" do
    let(:time) { Time.at 1378132362 }
    let(:columns) do
      { id: { reverse: true }, custom: { reverse: false }, custom_time: { reverse: false } }
    end
    let(:cursor_value) { [1,2,time] }
    let(:cursor) { CursorPagination::Cursor.new cursor_value }

    context "with direct sql" do
      specify do
        target_sql = "(\"entities\".\"id\" < 1 OR \"entities\".\"id\" = 1 AND (\"entities\".\"custom\" > 2 OR \"entities\".\"custom\" = 2 AND \"entities\".\"custom_time\" > '2013-09-02 14:32:42.000000'))"
        where = Entity.send(:_cursor_to_where, columns, cursor_value)
        where.to_sql.should eq target_sql
      end
    end

    context "with reversed sql" do
      specify do
        target_sql = "(\"entities\".\"id\" > 1 OR \"entities\".\"id\" = 1 AND (\"entities\".\"custom\" < 2 OR \"entities\".\"custom\" = 2 AND \"entities\".\"custom_time\" <= '2013-09-02 14:32:42.000000'))"
        where = Entity.send(:_cursor_to_where, columns, cursor_value, true)
        where.to_sql.should eq target_sql
      end
    end
  end
end
