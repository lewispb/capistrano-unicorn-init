require 'capistrano'
require 'shadow_puppet'
require 'capistrano-unicorn-init/manifest'

Dir.glob(File.join(File.dirname(__FILE__), '..', '/recipes/*.rb')).sort.each { |f| puts f; load f }
