# FIXME: No clue what sferik/twitter looks like yet
#
class SessionsController < ApplicationController
  # ssl_required :new, :create

  def new
    current_user = nil
    @user = User.new
  end

  def create
    oauth.set_callback_url(login_callback_url)

    session['rtoken'] = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret

    redirect_to oauth.request_token.authorize_url

  end

  def login_callback
    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])

    session['rtoken'] = nil
    session['rsecret'] = nil

    profile = Twitter::Base.new(oauth).verify_credentials
    user = User.find_or_create_by_login(profile.screen_name)

    user.update_attributes({
      :twitter_rtoken => oauth.access_token.token,
      :twitter_rsecret => oauth.access_token.secret
    })

    sign_in(user)

    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private
    def oauth
      @oauth ||= Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    end

end
