
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'firetower'
  authors  'Avdi Grimm'
  email    'avdi@avdi.org'
  url      'http://github.com/avdi/firetower'

  summary "A command-line interface to Campfire chats"

  readme_file 'README.org'

  depend_on 'twitter-stream',   '~> 0.1.6'
  depend_on 'eventmachine',     '~> 0.12.10'
  depend_on 'json',             '~> 1.4'
  depend_on 'addressable',      '~> 2.1'
  depend_on 'main',             '~> 4.2'
  depend_on 'servolux',         '~> 0.9.4'
  depend_on 'hookr',            '~> 1.0'
  depend_on 'highline',         '~> 1.5'
}

