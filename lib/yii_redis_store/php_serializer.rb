require 'php-serialize'

module YiiRedisStore
  class PhpSerializer
    def self.dump(value)
      PHP.serialize_session(value)
    end

    def self.load(value)
      PHP.unserialize(value)
    end
  end
end
