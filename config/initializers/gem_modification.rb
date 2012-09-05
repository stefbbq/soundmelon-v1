
module Sorcery
  module Controller
    module Submodules
      module External
        module InstanceMethods

          # sends user to authenticate at the provider's website.
          # after authentication the user is redirected to the callback defined in the provider config
          def login_at(provider, args = {})
            logger.error "Accessing ....#{Time.now.to_s} - #{args}"
            @provider     = Config.send(provider)
            arg_string    = ""
            args.each do |key, value|
              arg_string  += "&#{key}=#{value}"
            end            
            if @provider.callback_url.present? && @provider.callback_url[0] == '/'
              uri = URI.parse(request.url.gsub(/\?.*$/,''))
              uri.path = ''
              uri.query = nil
              uri.scheme = 'https' if(request.env['HTTP_X_FORWARDED_PROTO'] == 'https')
              host = uri.to_s
              
              callback_url = "#{host}#{@provider.callback_url}"
              callback_url += "#{arg_string}" unless arg_string.blank?
              @provider.callback_url = callback_url
              logger.error "Calling the url #{callback_url} -- #{@provider.callback_url}"                          
            end            
            if @provider.has_callback?
              redirect_to @provider.login_url(params,session)
            else
              #@provider.login(args)
            end
          end

          def get_user_detail provider
            @provider   = Config.send(provider)
            @provider.process_callback(params,session)
            @user_hash  = @provider.get_user_hash
            @user_hash
            h                               = {}
            h[:user]                        = {}
            h[:user][:email]                = @user_hash[:user_info]["email"]
            h[:user][:email_confirmation]   = @user_hash[:user_info]["email"]
            h[:user][:fname]                = @user_hash[:user_info]["first_name"]
            h[:user][:lname]                = @user_hash[:user_info]["last_name"]
            h[:user][:mention_name]         = @user_hash[:user_info]["username"]
            h[:user][:is_external]          = true
            h[:uid]                         = @user_hash[:user_info]["id"]
            h
          end
          
        end
      end
    end
  end
end