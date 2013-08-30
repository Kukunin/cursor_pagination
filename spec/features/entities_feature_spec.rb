require 'spec_helper'

describe EntitiesController do

  include_context "entities"

  before { visit entities_path }
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
