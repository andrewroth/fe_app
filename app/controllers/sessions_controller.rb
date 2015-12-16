class SessionsController < ApplicationController
  skip_before_action :require_login

  def create
    omniauth = request.env['omniauth.auth']
    session.delete(:person_id)

    # cas example:
    # => {"provider"=>:cas,
    #  "uid"=>"ANDREWROTH@GMAIL.COM",
    #  "info"=>{"email"=>"ANDREWROTH@GMAIL.COM", "nickname"=>"ANDREWROTH@GMAIL.COM"},
    #  "credentials"=>{"ticket"=>"ST-12345-ABCDEFGHIJLKMNO-asdfgh12"},
    #  "extra"=>{"user"=>"ANDREWROTH@GMAIL.COM", "lastName"=>"Roth", "username"=>"ANDREWROTH@GMAIL.COM", "ssoGuid"=>"1a1aaa11-1a1a-11a1-aa11-1111aa1a11a1", "firstName"=>"Andrew"}}

    # fb example:
    #=> {"provider"=>"facebook",
    # "uid"=>"11111111111111111",
    # "info"=>
    #  {"email"=>"andrewroth@gmail.com",
    #   "name"=>"Andrew Roth",
    #   "first_name"=>"Andrew",
    #   "last_name"=>"Roth",
    #   "image"=>"http://graph.facebook.com/v2.0/11111111111111111/picture",
    #   "urls"=>{"Facebook"=>"https://www.facebook.com/app_scoped_user_id/11111111111111111/"},
    #   "verified"=>true},
    # "credentials"=>
    #  {"token"=>
    #    "DFrrKJSFfLdJkFSjKJjjjfdslsdlfjkKLJFDSLKJFDlkjFDLKJfdlkjDFSLKfsdjFLDSKJFdslkfDSJfdlskjFDSLKfdjDFSLKJfdslkFDSJdfslkjsdflkjogidhjgsdkfjsldkfjlkjlkjfdslfkdjfsdlkjfdsfsdlkjfsdlLKJlkjLKJfllfjkFLKJflkjFLKjfFLKJflkjfLKfjff",
    #   "expires_at"=>1432662035,
    #   "expires"=>true},
    # "extra"=>
    #  {"raw_info"=>
    #    {"id"=>"11111111111111111",
    #     "birthday"=>"11/22/1985",
    #     "email"=>"andrewroth@gmail.com",
    #     "first_name"=>"Andrew",
    #     "gender"=>"male",
    #     "last_name"=>"Roth",
    #     "link"=>"https://www.facebook.com/app_scoped_user_id/11111111111111111/",
    #     "locale"=>"en_US",
    #     "name"=>"Andrew Roth",
    #     "timezone"=>-4,
    #     "updated_time"=>"2014-11-25T16:52:43+0000",
    #     "verified"=>true}}}

    authentication = Authentication.where(provider: omniauth['provider'])
                     .where('upper(uid) = ?', omniauth_uid(omniauth).upcase).first

    unless authentication
      person = Fe::Person.create_from_omniauth(omniauth)
      authentication = Authentication.new
      authentication.provider = omniauth['provider']
      authentication.uid = omniauth_uid(omniauth)
      authentication.username = omniauth_username(omniauth)
      authentication.token = omniauth['credentials']['token'] || omniauth[:credentials][:ticket] if omniauth['credentials']
      authentication.person = person
    end
    authentication.last_login = Time.now
    authentication.save!
    session[:person_id] = authentication.person.id
    session[:attempted_submit] = false
    flash[:notice] = 'Signed in!'
    redirect_to after_signin_path
  end

  def destroy
    if logged_in?
      if session[:impersonate_person_id]
        session[:id] = session[:impersonate_person_id]
        session[:impersonate_person_id] = nil
        session.delete(:impersonate_person_id)
        redirect_to root_path
        return
      else
        latest_auth = current_person.authentications.order('last_login desc').first
        if latest_auth.provider == 'cas'
          redirect_to "https://signin.relaysso.org/cas/logout?service=#{root_url}"
        else
          redirect_to root_path, notice: 'Signed out!'
        end
      end
      reset_session
    else
      redirect_to root_path
    end
  end

  def logout_callback
    # noop
  end

  def failure
    redirect_to root_path, alert: "Authentication error: #{params[:message].humanize}"
  end

  protected

  def root_url
    '/'
  end

  def after_signin_path
    root_path
  end

  def omniauth_uid(omniauth)
    case omniauth['provider'].to_s
    when 'cas'
      omniauth['extra']['ssoGuid']
    when 'facebook'
      omniauth['uid']
    end
  end

  def omniauth_username(omniauth)
    case omniauth['provider'].to_s
    when 'cas'
      omniauth['extra']['username'] if omniauth['extra']
    when 'facebook'
      omniauth['info']['email']
    end
  end
end
