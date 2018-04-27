require 'minitest/autorun'
require 'mocha/minitest'
require 'logger'

require 'kashmir'

Kashmir.init({
  logger: Logger.new("/dev/null")
})
