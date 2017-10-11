require 'rails_helper'

require 'support/models'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'passing params', type: :request do
  before(:each) do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Category) do
        select2_options(scope: ->(params) { Category.where(created_by_id: params[:created_by]) },
                        text_attribute: :name)
      end

      ActiveAdmin.register(Post) do
        form do |f|
          f.input(:category,
                  as: :select2,
                  ajax: {
                    params: {
                      created_by: current_user.id
                    }
                  })
        end
      end
    end
  end

  it 'passes parameters when rendering selected item' do
    user = User.create
    category = Category.create(name: 'Travel', created_by: user)
    post = Post.create(category: category)

    ApplicationController.current_user = user
    get "/admin/posts/#{post.id}/edit"

    expect(response.body).to have_selector('.select2-input option[selected]',
                                           text: 'Travel')
  end

  it 'includes parameters in ajax url' do
    user = User.create

    ApplicationController.current_user = user
    get '/admin/posts/new'

    url_matcher = "?created_by=#{user.id}"
    expect(response.body).to have_selector(".select2-input[data-ajax-url*='#{url_matcher}']")
  end
end
