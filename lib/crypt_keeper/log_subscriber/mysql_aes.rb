if !CryptKeeper.legacy_mode?
  require 'active_support/concern'
  require 'active_support/lazy_load_hooks'
end

module CryptKeeper
  module LogSubscriber
    module MysqlAes

      def self.included(klass)
        alias_method_chain :sql, :mysql_aes
      end

      # Public: Prevents sensitive data from being logged
      def sql_with_mysql_aes(event)
        filter = /(aes_(encrypt|decrypt))\(((.|\n)*?)\)/i

        event.payload[:sql] = event.payload[:sql].gsub(filter) do |_|
          "#{$1}([FILTERED])"
        end

        sql_without_mysql_aes(event)
      end
    end
  end
end

if CryptKeeper.legacy_mode?
  ActiveRecord::LogSubscriber.send :include, CryptKeeper::LogSubscriber::MysqlAes
end