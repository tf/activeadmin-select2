require 'rails_helper'

require 'support/temping'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'select2 filter inputs', type: :request do
  before(:each) do
    Temping.create(:user) do
      with_columns do |t|
        t.string :name
      end
    end

    Temping.create(:category) do
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
  end

  let!(:current_user) do
    ApplicationController.current_user = User.create!
  end

  describe 'without ajax option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          filter :category, type: :select2
        end
      end
    end

    it 'renders select input with select2-input css class' do
      get '/admin/posts'

      expect(response.body).to have_selector('select.select2-input')
    end

    it 'renders options statically' do
      Category.create!(name: 'Travel')
      Category.create!(name: 'Music')

      get '/admin/posts'

      expect(response.body).to have_selector('.select2-input option', text: 'Travel')
      expect(response.body).to have_selector('.select2-input option', text: 'Music')
    end

    it 'does not set data-ajax-url attribute' do
      get '/admin/posts'

      expect(response.body).not_to have_selector('.select2-input[data-ajax-url]')
    end
  end

  describe 'with ajax option set to true' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          select2_options(scope: Category, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category,
                 type: :select2,
                 ajax: true)
        end
      end
    end

    it 'renders select input with select2-input css class' do
      get '/admin/posts'

      expect(response.body).to have_selector('select.select2-input')
    end

    it 'renders does not render options statically' do
      Category.create!(name: 'Travel')

      get '/admin/posts'

      expect(p(response.body)).not_to have_selector('.select2-input option', text: 'Travel')
    end

    it 'sets data-ajax-url attribute' do
      get '/admin/posts'

      expect(response.body).to have_selector('.select2-input[data-ajax-url]')
    end
  end
end
