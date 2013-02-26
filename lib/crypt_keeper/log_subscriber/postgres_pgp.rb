if !CryptKeeper.legacy_mode?
  require 'active_support/concern'
  require 'active_support/lazy_load_hooks'
end

module CryptKeeper
  module LogSubscriber
    module PostgresPgp

      def self.included(klass)
        alias_method_chain :sql, :postgres_pgp
      end

      # Public: Prevents sensitive data from being logged
      def sql_with_postgres_pgp(event)
        filter = /(pgp_sym_(encrypt|decrypt))\(((.|\n)*?)\)/i

        event.payload[:sql] = event.payload[:sql].gsub(filter) do |_|
          "#{$1}([FILTERED])"
        end

        sql_without_postgres_pgp(event)
      end
    end
  end
end

if CryptKeeper.legacy_mode?
  ActiveRecord::LogSubscriber.send :include, CryptKeeper::LogSubscriber::PostgresPgp
end