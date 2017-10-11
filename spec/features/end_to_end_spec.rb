require 'rails_helper'

require 'support/temping'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'end to end', type: :feature, js: true do
  before(:each) do
    sleep 1

    Temping.create(:category, temporary: false) do
      with_columns do |t|
        t.string :name
      end
    end

    # Do not make posts table temporary to make Ransack table
    # detection work
    Temping.create(:post, temporary: false) do
      with_columns do |t|
        t.string :title
        t.belongs_to :category
      end

      belongs_to :category
    end

    ActiveAdminHelpers.setup do
      ActiveAdmin.setup {}

      ActiveAdmin.register(Category) do
        select2_options(scope: Category, text_attribute: :name)
      end

      ActiveAdmin.register(Post) do
        filter(:category, as: :select2, ajax: true)

        form do |f|
          f.input(:category, as: select2, ajax: true)
        end
      end
    end
  end

  describe 'index page with select2 filter' do
    before(:each) do
      music_category = Category.create(name: 'Music')
      travel_category = Category.create(name: 'Travel')

      Post.create(title: 'Best songs',
                  category: music_category)
      Post.create(title: 'Best places',
                  category: travel_category)
    end

    it 'loads filter input options' do
      visit '/admin/posts'

      expand_select_box

      expect(select_box_items).to eq(%w[Music Travel])
    end

    it 'allows filtering options by term' do
      visit '/admin/posts'

      expand_select_box

      wait_for_ajax do
        enter_search_term('T')
      end

      expect(select_box_items).to eq(%w[Travel])
    end
  end

  def expand_select_box
    find('.select2-container').click
  end

  def enter_search_term(term)
    find('.select2-dropdown input').send_keys(term)
  end

  def select_box_items
    all('.select2-dropdown li').map(&:text)
  end

  def wait_for_ajax(count = 1)
    page.execute_script 'window._ajaxCalls = 0'
    page.execute_script 'window._ajaxCompleteCounter = function() { window._ajaxCalls += 1; }'
    page.execute_script '$(document).ajaxComplete(window._ajaxCompleteCounter)'

    yield

    until finished_all_ajax_requests?(count)
      sleep 0.5
    end
  end

  def finished_all_ajax_requests?(count)
    page.evaluate_script('window._ajaxCalls') == count
  end
end
