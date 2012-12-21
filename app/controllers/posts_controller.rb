class PostsController < ApplicationController
  before_filter :reset_session, except: [:show]
  before_filter :authenticate_with_oauth_echo, except: [:show]
  skip_before_filter :verify_authenticity_token
  ssl_allowed

  def show
    @post = Post.where(short_id: params[:id])
    redirect_to @post.flickr_url
  end

  def create
    if current_user && params[:media].present? && current_user.flickr_token.present?
      @post = post.new(params)
      @post.user = current_user
      if @post.save
        response = @post.as_response
      else
        response = {errors: @post.errors, status: 400}
      end
      respond_to do |format|
        format.xml do
          render xml: response, status: (response[:status] rescue 200)
        end
        format.json do
          render json: response, status: (response[:status] rescue 200)
        end
      end
    end
  end

  def create_from
    method = "create_from_#{service}".to_sym
    if self.respond_to? method
      send method
    else
      not_found
    end
  end

  protected

  def authenticate_with_oauth_echo
    require 'httparty'
    # header auth only for now; also lock down the auth provider so we can't spoof
    if request.env["HTTP_X_AUTH_SERVICE_PROVIDER"] =~ /^https:\/\/api\.twitter\.com\//
      auth_service_provider = request.env["HTTP_X_AUTH_SERVICE_PROVIDER"]
      verify_credentials_authorization = request.env["HTTP_X_VERIFY_CREDENTIALS_AUTHORIZATION"]
      logger.info "provider: #{auth_service_provider}"
      logger.info "headers: #{verify_credentials_authorization}"
      auth_response = HTTParty.get(auth_service_provider, :format => :json, :headers => {'Authorization' => verify_credentials_authorization})
      if !auth_response['screen_name'].blank?
        log_in_user User.first(username: auth_response['screen_name'])
        return true
      end
    end
    return false
  end

end