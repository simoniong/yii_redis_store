require "yii_redis_store/php_serializer"
require "action_dispatch/middleware/session/redis_store"

module ActionDispatch
  module Session
    class YiiRedisStore < RedisStore
      def initialize(app, options = {})
        options = options.dup
        options = normalize_server_options(options)
        options[:redis_server] ||= options[:servers]
        super
      end

      def normalize_server_options(options)
        if options[:servers].any?
          options[:servers].map { |server| server[:serializer] ||= ::YiiRedisStore::PhpSerializer }
        end
        options
      end

      # yii tranform the session_id using custom rule
      def yii_session_id(sid)
        Digest::MD5.hexdigest(::YiiRedisStore.session_digest).first(5) +
          Digest::MD5.hexdigest(['yii\redis\Session', sid].to_json)
      end

      def get_session(env, sid)
        if env["rack.session.options"][:skip]
          [generate_sid, {}]
        else
          with_lock(env, [nil, {}]) do
            unless sid && (session = with { |c| c.get(yii_session_id(sid)) })
              session = {}
              sid = generate_unique_sid(session)
            end
            [sid, session]
          end
        end
      end

      def set_session(env, session_id, new_session, options)
        with_lock(env, false) do
          with { |c| c.set yii_session_id(session_id), new_session, options }
          session_id
        end
      end
    end
  end
end
