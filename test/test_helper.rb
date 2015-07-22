require 'minitest/autorun'
require 'mocha/test_unit'

require 'kashmir'

Kashmir.init({
  logger: Logger.new("/dev/null")
})
