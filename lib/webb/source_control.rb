$LOAD_PATH.unshift(__dir__)

module Webb
  module SourceControl
    autoload :Base, 'source_controls/base'
    autoload :Github, 'source_controls/github'
  end
end
