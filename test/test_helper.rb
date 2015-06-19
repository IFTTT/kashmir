require 'byebug'
require 'minitest/autorun'
require 'minitest/ansi'
require 'mocha/mini_test'

require 'kashmir'

Kashmir.init({
  logger: Logger.new("/dev/null")
})
