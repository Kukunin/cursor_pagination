require 'spec_helper'

describe Entity do
  specify do
    entity = Entity.create!
    new_entity = Entity.find entity.id
    entity.should eq new_entity
  end
end
