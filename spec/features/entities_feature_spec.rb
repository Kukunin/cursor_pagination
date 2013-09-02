require 'spec_helper'

describe EntitiesController do

  subject { page }

  shared_examples_for "first page" do
    it { should have_content "Custom 1" }
    it { should_not have_link "Previous Page" }
    it { should have_link "Next Page" }
  end
  shared_examples_for "second page" do
    it { should have_content "Custom 2" }
    it { should have_link "Previous Page" }
    it { should have_link "Next Page" }
  end
  shared_examples_for "third page" do
    it { should have_content "Custom 3" }
    it { should have_link "Previous Page" }
    it { should have_link "Next Page" }
  end
  shared_examples_for "last page" do
    it { should have_content "Custom 4" }
    it { should have_link "Previous Page" }
    it { should_not have_link "Next Page" }
  end
  shared_examples_for "previous first page" do
    describe "previous page" do
      before { click_link "Previous Page" }
      it_should_behave_like "first page"
    end
  end
  shared_examples_for "previous second page" do
    describe "previous page" do
      before { click_link "Previous Page" }
      it_should_behave_like "second page"

      it_should_behave_like "previous first page"
    end
  end


  shared_examples_for "cursor pagination" do
    it_should_behave_like "first page"

    describe "second page" do
      before { click_link "Next Page" }
      it_should_behave_like "second page"

      describe "third page" do
        before { click_link "Next Page" }
        it_should_behave_like "third page"

        describe "last page" do
          before { click_link "Next Page" }
          it_should_behave_like "last page"

          describe "previous page" do
            before { click_link "Previous Page" }
            it_should_behave_like "third page"

            it_should_behave_like "previous second page"
          end
        end

        it_should_behave_like "previous second page"
      end

      it_should_behave_like "previous first page"
    end
  end

  context "by custom" do
    include_context "entities"

    before { visit entities_path }

    it_should_behave_like "cursor pagination"
  end

  context "by two-columns" do
    before do
      two_minutes_ago = 2.minutes.ago
      Entity.create! custom: 1, custom_time: 1.minute.ago
      Entity.create! custom: 3, custom_time: two_minutes_ago
      Entity.create! custom: 2, custom_time: two_minutes_ago
      Entity.create! custom: 4, custom_time: 3.minutes.ago

      visit two_column_entities_path
    end

    it_should_behave_like "cursor pagination"
  end

end
