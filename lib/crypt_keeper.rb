module CryptKeeper
  def CryptKeeper.legacy_mode?
    @legacy_mode ||= !ActiveSupport.respond_to?(:on_load) || (ActiveRecord::VERSION::MAJOR < 3)
  end
end

require 'active_record'
require 'crypt_keeper/model'
require 'crypt_keeper/helper'

if CryptKeeper.legacy_mode?
  ActiveRecord::Base.class_eval do
    include CryptKeeper::Model
  end
else
  require 'crypt_keeper/version'
    
  ActiveSupport.on_load :active_record do
    include CryptKeeper::Model
  end
  
  ActiveSupport.on_load :crypt_keeper_mysql_aes_log do
    ActiveRecord::LogSubscriber.send :include, CryptKeeper::LogSubscriber::MysqlAes
  end
  
  ActiveSupport.on_load :crypt_keeper_posgres_pgp_log do
    ActiveRecord::LogSubscriber.send :include, CryptKeeper::LogSubscriber::PostgresPgp
  end
end