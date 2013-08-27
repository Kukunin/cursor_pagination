require 'spec_helper'

describe Entity do
  describe "#cursor method" do
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
end
