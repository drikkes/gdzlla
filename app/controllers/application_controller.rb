class ApplicationController < ActionController::Base
  # include SslRequirement

  helper :all
  protect_from_forgery

  protected

    def ssl_required?
      RAILS_ENV != 'development' && super
    end
end
