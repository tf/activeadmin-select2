require 'rails_helper'

require 'support/temping'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'select2 input', type: :request do
  before(:each) do
    Temping.create(:category) do
      with_columns do |t|
        t.string :name
      end
    end

    Temping.create(:post) do
      with_columns do |t|
        t.string :title
        t.belongs_to :category
      end

      belongs_to :category
    end
  end

  it 'fails with helpful error message if ajax resource cannot be auto detected' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          filter(:category_id_eq,
                 as: :select2,
                 ajax: true)
        end
      end

      get '/admin/posts'
    end.to raise_error(/Cannot auto detect resource/)
  end

  it 'fails with helpful error message if named option collection does not exist' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          select2_options(scope: Category, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category,
                 as: :select2,
                 ajax: {
                   collection_name: 'custom'
                 })
        end
      end

      get '/admin/posts'
    end.to raise_error(/No option collection named 'custom' defined in 'Category' admin./)
  end

  it 'fails with helpful error message if ajax resource does not have an admin' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          filter(:category,
                 as: :select2,
                 ajax: true)
        end
      end

      get '/admin/posts'
    end.to raise_error(/No admin found for 'Category'/)
  end
end
