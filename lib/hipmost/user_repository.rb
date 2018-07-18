require 'json'

module Hipmost
  class UserRepository
    attr_accessor :users
    extend Forwardable

    def_delegators :@users, :size, :[], :select


    def load_from(path)
      new(path).load
    end

    def initialize(path)
      @path  = Pathname.new(path).join("users.json")
      @users = {}
    end

    def load(data = file_data)
      json = JSON.load(data)

      json.each do |user_obj|
        user = user_obj["User"]
        @users[user["id"]] = User.new(user)
      end
    end

    def file_data
      File.read(@path)
    end

    class User
      def initialize(attrs)
        @id    = attrs["id"]
        @attrs = attrs
      end
      attr_reader :id, :attrs

      def guest?
        attrs["account_type"] == "guest"
      end

      def inactive?
        attrs["is_deleted"]
      end

      def method_missing(method)
        attrs[method]
      end
    end
  end
end
