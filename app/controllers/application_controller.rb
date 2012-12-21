class ApplicationController < ActionController::Base
  include SslRequirement

  helper :all
  protect_from_forgery

  protected

    def ssl_required?
      RAILS_ENV != 'development' && super
    end

    def current_user
      @current_user ||= User.find(session[:user_id]) rescue nil
    end
    helper_method :current_user

    def signed_in?
      current_user.present?
    end
    helper_method :signed_in?

    def authentication_required
      unless signed_in?
        flash[:error] = "You must be logged in to do that."
        redirect_to root_path and return
      end
    end

    def log_in_user(user=nil)
      @current_user = nil
      session[:user_id] = user.id
    end

    def setting(key)
      GDZLLA.setting key
    end
    helper_method :setting

    def ensure_user_is_current_user(user=nil)
      user = (@user rescue nil) if user.nil?
      if user != current_user
        flash[:error] = 'You can\'t do that!'
        redirect_to :back and return
      end
    end
    helper_method :ensure_user_is_current_user

    def get_flickr_client
      Flickr.new(key: setting(:flickr_key), secret: setting(:flickr_secret))
    end
    helper_method :get_flickr_client

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
end
