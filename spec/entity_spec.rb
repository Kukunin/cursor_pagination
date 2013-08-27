require 'spec_helper'

describe Entity do

  before do
    4.times { |n| Entity.create! custom: (4 - n)}
  end

  let(:entities) { Entity.all.to_a }
  let(:first_entity) { entities.first }
  let(:second_entity) { entities[1] }
  let(:third_entity) { entities[2] }
  let(:last_entity) { entities[3] }

  specify do
    first_entity.id.should be < second_entity.id
    first_entity.custom.should be > second_entity.custom
  end

  describe "#cursor method" do
    it "returns first entity only" do
      result = Entity.cursor(nil).per(1).to_a
      result.size.should eq 1
      result.first.should eq first_entity
    end

    it "returns second entity only" do
      result = Entity.cursor(first_entity.id).per(1).to_a
      result.size.should eq 1
      result.first.should eq second_entity
    end

    it "support different orders" do
      result = Entity.order('id DESC').cursor(second_entity.id, reverse: true).per(1).to_a
      result.size.should eq 1
      result.first.should eq first_entity
    end

    it "support different columns" do
      result = Entity.cursor(second_entity.id, column: :custom).per(1).to_a
      result.size.should eq 1
      result.first.should eq first_entity
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
      specify { Entity.cursor(nil).per(10).next_cursor.should eq -1 }
      specify { Entity.cursor(nil).per(10).should be_last_page }
      specify { Entity.cursor(nil).per(1).next_cursor.should eq first_entity.id}
      specify { Entity.cursor(nil).per(1).should_not be_last_page}
      specify { Entity.cursor(third_entity.id).next_cursor.should eq -1 }

      ##Reverse order
      specify { Entity.order('id DESC').cursor(nil, reverse: true).per(1).next_cursor.should eq last_entity.id }
      specify { Entity.order('id DESC').cursor(second_entity.id, reverse: true).per(1).next_cursor.should eq -1 }

      ##With custom column
      specify { Entity.order('custom ASC').cursor(second_entity.custom, column: :custom).per(1).next_cursor.should eq -1 }
      specify { Entity.order('custom ASC').cursor(third_entity.custom, column: :custom).per(1).next_cursor.should eq second_entity.custom }
      specify { Entity.order('custom ASC').cursor(nil, column: :custom).per(1).next_cursor.should eq last_entity.custom }
    end

    describe "#previous_cursor" do
      ##Default settings
      #no previous page
      specify { Entity.cursor(nil).previous_cursor.should eq -1 }
      specify { Entity.cursor(nil).should be_first_page }
      #not full previous page
      specify { Entity.cursor(first_entity.id).previous_cursor.should be_nil }
      specify { Entity.cursor(first_entity.id).should_not be_first_page }
      #full previous page
      specify { Entity.cursor(second_entity.id).per(1).previous_cursor.should eq first_entity.id }
      specify { Entity.cursor(second_entity.id).per(1).should_not be_first_page }

      ##Reverse order
      specify { Entity.order('id DESC').cursor(nil, reverse: true).previous_cursor.should eq -1 }
      specify { Entity.order('id DESC').cursor(last_entity.id, reverse: true).previous_cursor.should be_nil }
      specify { Entity.order('id DESC').cursor(third_entity.id, reverse: true).per(1).previous_cursor.should eq last_entity.id }

      ##With custom column
      specify { Entity.order('custom ASC').cursor(nil, column: :custom).previous_cursor.should eq -1 }
      specify { Entity.order('custom ASC').cursor(last_entity.custom, column: :custom).previous_cursor.should be_nil }
      specify { Entity.order('custom ASC').cursor(third_entity.custom, column: :custom).per(1).previous_cursor.should eq last_entity.custom }
    end
  end
end
