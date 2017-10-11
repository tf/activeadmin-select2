module ActiveAdminHelpers
  extend self

  def setup
    ActiveAdmin.unload!
    yield
    Rails.application.reload_routes!
  end
end
