ENV['RACK_ENV'] = 'test'
ENV['REDISCLOUD_URL'] = 'redis://localhost:6379/2'
require './config/application'
require './app'

prepare do
  Ohm.flush
  pwd = Digest::SHA256.hexdigest 'alagranja'
  User.create name: 'alagranja', password: "#{pwd}"
  Cash.instance.total = 0
end
