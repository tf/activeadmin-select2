require 'rails_helper'

require 'support/temping'
require 'support/active_admin_helpers'

RSpec.describe 'select2_options dsl', type: :request do
  before(:each) do
    Temping.create(:user) do
      with_columns do |t|
        t.string :name
      end
    end

    # Do not make posts table temporary to make Ransack table
    # detection work
    Temping.create(:post, temporary: false) do
      with_columns do |t|
        t.string :title
        t.belongs_to :user
        t.boolean :published
      end

      belongs_to :user

      scope(:published, -> { where(published: true) })
    end
  end

  let!(:current_user) do
    ApplicationController.current_user = User.create!
  end

  describe 'creates JSON endpoint that' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          select2_options(scope: Post, text_attribute: :title)
        end
      end
    end

    it 'returns options for select2' do
      Post.create!(title: 'A post')

      get '/admin/posts/all_options'

      expect(json_response).to match(results: [a_hash_including(text: 'A post',
                                                                id: kind_of(Numeric))])
    end

    it 'supports filtering via term parameter' do
      Post.create!(title: 'A post')
      Post.create!(title: 'Other post')
      Post.create!(title: 'Not matched')

      get '/admin/posts/all_options?term=post'
      titles = json_response[:results].pluck(:text)

      expect(titles).to eq(['A post', 'Other post'])
    end

    it 'supports limiting number of results' do
      Post.create!(title: 'A post')
      Post.create!(title: 'Other post')
      Post.create!(title: 'Yet another post')

      get '/admin/posts/all_options?limit=2'

      expect(json_response[:results].size).to eq(2)
    end
  end

  it 'allows passing lambda as scope' do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Post) do
        select2_options(scope: -> { Post.published },
                        text_attribute: :title)
      end
    end

    Post.create!(title: 'Draft')
    Post.create!(title: 'Published post', published: true)

    get '/admin/posts/all_options'
    titles = json_response[:results].pluck(:text)

    expect(titles).to eq(['Published post'])
  end

  it 'allows passing lambda as scope that takes current user as argument' do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Post) do
        select2_options(scope: ->(current_user) { Post.where(user: current_user) },
                        text_attribute: :title)
      end
    end

    Post.create!(title: 'By current user', user: current_user)
    Post.create!(title: 'By other user', user: User.create!)

    get '/admin/posts/all_options'
    titles = json_response[:results].pluck(:text)

    expect(titles).to eq(['By current user'])
  end

  it 'allows passing name prefix for collection action' do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Post) do
        select2_options(name: :some,
                        scope: Post,
                        text_attribute: :title)
      end
    end

    Post.create!(title: 'A post')

    get '/admin/posts/some_options'

    expect(json_response).to match(results: array_including(a_hash_including(text: 'A post')))
  end

  it 'fails with helpful message if scope option is missing' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          select2_options(text_attribute: :title)
        end
      end
    end.to raise_error(/Missing option: scope/)
  end

  it 'fails with helpful message if text_attribute option is missing' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          select2_options(scope: Post)
        end
      end
    end.to raise_error(/Missing option: text_attribute/)
  end

  def json_response
    JSON.parse(response.body).with_indifferent_access
  end
end
