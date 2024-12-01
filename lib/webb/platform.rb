$LOAD_PATH.unshift(__dir__)

module Webb
  module Platform
    autoload :Base, 'platforms/base'
    autoload :Github, 'platforms/github'
  end
end
