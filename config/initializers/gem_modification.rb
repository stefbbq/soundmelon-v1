## this method automatically creates a new user from the data in the external user hash.
## The mappings from user hash fields to user db fields are set at controller config.
## If the hash field you would like to map is nested, use slashes. For example, Given a hash like:
##
##   "user" => {"name"=>"moishe"}
##
## You will set the mapping:
##
##   {:username => "user/name"}
##
## And this will cause 'moishe' to be set as the value of :username field.
## Note: Be careful. This method skips validations model.
## Instead you can pass a block, if the block returns false the user will not be created
##
##   create_from(provider) {|user| user.some_check }
##
#Sorcery::Controller::Submodules::External::InstanceMethods.module_eval do
#  def create_from(provider)
#    provider    = provider.to_sym
#    @provider   = Config.send(provider)
#    @user_hash  = @provider.get_user_hash
#    config      = user_class.sorcery_config
#
#    attrs = user_attrs(@provider.user_info_mapping, @user_hash)
##    logger.error "=====> #{attrs.inspect} =>>>"
#    user_class.transaction do
#      @user = user_class.new()
#      attrs.each do |k,v|
#        @user.send(:"#{k}=", v)
#      end
#
#      if block_given?
#        return false unless yield @user
#      end
#
#      @user.save(:validate => false)
#      user_class.sorcery_config.authentications_class.create!({config.authentications_user_id_attribute_name => @user.id, config.provider_attribute_name => provider, config.provider_uid_attribute_name => @user_hash[:uid]})
#    end
#    @user
#  end
#end