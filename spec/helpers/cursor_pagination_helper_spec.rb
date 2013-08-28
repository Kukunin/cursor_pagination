require 'spec_helper'

describe CursorPagination::ActionViewHelper do

  include_context "entities"

  describe '#previous_cursor_link' do
    context 'having previous pages' do
      context 'the default behaviour' do
        subject { helper.previous_cursor_link second_page, 'Previous', {:controller => 'entities', :action => 'index'} }
        it { should be_a String }
        it { should match(/rel="previous"/) }
        it { should_not match(/cursor=/) }
      end
      context 'the third page' do
        subject { helper.previous_cursor_link third_page, 'Previous', {:controller => 'entities', :action => 'index'} }
        it { should be_a String }
        it { should match(/rel="previous"/) }
        it { should match(/cursor=#{first_entity.id}/) }
      end
      context 'overriding rel=' do
        subject { helper.previous_cursor_link second_page, 'Previous', {:controller => 'entities', :action => 'index'}, {:rel => 'external'} }
        it { should match(/rel="external"/) }
      end
    end
    context 'the first page' do
      subject { helper.previous_cursor_link first_page, 'Previous', {:controller => 'entities', :action => 'index'} }
      it { should be_nil }
    end
  end

  describe '#next_cursor_link' do
    context 'having more page' do
      context 'the default behaviour' do
        subject { helper.next_cursor_link first_page, 'More', {:controller => 'entities', :action => 'index'} }
        it { should be_a String }
        it { should match(/rel="next"/) }
        it { should match(/cursor=#{first_entity.id}/) }
      end
      context 'overriding rel=' do
        subject { helper.next_cursor_link first_page, 'More', {:controller => 'entities', :action => 'index'}, { :rel => 'external' } }
        it { should match(/rel="external"/) }
      end
    end
    context 'the last page' do
      subject { helper.next_cursor_link last_page, 'More', {:controller => 'entities', :action => 'index'} }
      it { should be_nil }
    end
  end

end
