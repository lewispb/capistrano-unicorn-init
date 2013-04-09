module Capistrano
  module UnicornInit
    TASKS = [
      'unicorn:setup',
      'unicorn:start',
      'unicorn:stop',
      'unicorn:restart',
      'unicorn:duplicate',
      'unicorn:reload',
      'unicorn:shutdown',
      'unicorn:add_worker',
      'unicorn:remove_worker'
    ]

    def self.load_into(configuration)
      configuration.load do

        def init_filename
          "#{fetch(:application)}-unicorn"
        end

        def init_path
         "/etc/init.d/#{init_filename}"
        end

        def init_content
          file = File.join(
            File.dirname(__FILE__), '..', 'templates', 'unicorn.init.erb')
          template(file, binding)
        end

        def setup_init
          init = StringIO.new(init_content)
          upload(init, '/tmp/unicorn')

          commands = [
            "mv /tmp/unicorn #{init_path}",
            "sudo chmod +x #{init_path}",
            "sudo update-rc.d -f #{init_filename} remove",
            "sudo update-rc.d #{init_filename} defaults"
          ]

          sudo commands.join ' && '
        end

        def binary_content
          file = File.join(
            File.dirname(__FILE__), '..', 'templates', 'unicorn.exec')
          File.read(file)
        end

        def binary_path
          "#{fetch(:deploy_to)}/shared/binary/unicorn"
        end

        def setup_binary
          binary = StringIO.new(binary_content)
          run "mkdir -p #{File.dirname(binary_path)}"
          upload(binary, binary_path)
          run "chmod +x #{binary_path}"
        end

        def template(pathname, b = binding)
          pathname = Pathname.new(pathname) unless pathname.kind_of?(Pathname)

          pathname = if pathname.exist?
                       pathname
                     else
                       raise LoadError, "Can't find template #{pathname}"
                     end
          erb = ERB.new(pathname.read)
          erb.filename = pathname.to_s
          erb.result(b)
        end

        namespace :unicorn do
          desc <<-DESC
          Restart unicorn
          DESC
          task :upgrade do
            sudo "#{init_path} upgrade"
          end

          desc "stop unicorn"
          task :stop do
            sudo "#{init_path} stop"
          end

          desc "start unicorn"
          task :start do
            sudo "#{init_path} start"
          end

          desc "Update the config file"
          task :update_config do
            env = fetch(:rails_env) || 'production'
            primary = "config/unicorn/#{env}.rb"
            secondary = "config/unicorn.rb"

            config = nil
            if Pathname.new(primary).exist?
              config = primary
            else
              config = secondary
            end

            upload config, "#{fetch(:deploy_to)}/shared/config/unicorn.rb"
          end

          desc "Setup unicorn: init, exec, and config files"
          task :setup do
            setup_init
            setup_binary
          end

        end
      end
    end
  end
end

# may as well load it if we have it
if Capistrano::Configuration.instance
  Capistrano::UnicornInit.load_into(Capistrano::Configuration.instance)
end
