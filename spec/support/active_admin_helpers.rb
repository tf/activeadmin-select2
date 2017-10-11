module ActiveAdminHelpers
  extend self

  def setup
    ActiveAdmin.application = nil
    yield
    Rails.application.reload_routes!
  end
end
