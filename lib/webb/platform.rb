$LOAD_PATH.unshift(__dir__)

module Webb
  module Platform
    autoload :Base, 'platforms/base'
    autoload :Github, 'platforms/github'
    autoload :Gitlab, 'platforms/gitlab'
  end
end
