require "yii_redis_store/version"
require "action_dispatch/middleware/session/yii_redis_store"

module YiiRedisStore
  mattr_accessor :session_digest
  @@session_digest = nil

  def self.setup
    yield self
  end
end
