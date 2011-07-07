require "rubygems"
require "bundler"
Bundler.setup(:default, :rake)

require 'bones'
require 'bones/plugins/git'
require 'bones/plugins/rspec'

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

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
  depend_on 'hookr',            '~> 1.1'
  depend_on 'highline',         '~> 1.5'
  depend_on 'yammer4r',         '~> 0.1.5'
  depend_on 'oauth',            '~> 0.4.3'
  depend_on 'launchy'
}

