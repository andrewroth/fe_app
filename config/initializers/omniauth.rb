OmniAuth.config.logger = Logger.new(STDOUT)
OmniAuth.logger.progname = "omniauth"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
    host: 'signin.relaysso.org',
    login_url: '/cas/login',
    service_validate_url: '/cas/serviceValidate'
end
