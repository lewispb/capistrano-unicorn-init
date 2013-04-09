require 'capistrano'

Dir.glob(File.join(File.dirname(__FILE__), '..', '/recipes/*.rb')).sort.each { |f| puts f; load f }
