shared_context "entities" do
  before do
    4.times { |n| Entity.create! custom: (4 - n)}
  end

  let(:entities) { Entity.all.to_a }
  let(:first_entity) { entities.first }
  let(:second_entity) { entities[1] }
  let(:third_entity) { entities[2] }
  let(:last_entity) { entities[3] }

  let(:first_page) { Entity.cursor(nil).per(1) }
  let(:second_page) { Entity.cursor(first_entity.id).per(1) }
  let(:third_page) { Entity.cursor(second_entity.id).per(1) }
  let(:last_page) { Entity.cursor(third_entity.id).per(1) }
end
