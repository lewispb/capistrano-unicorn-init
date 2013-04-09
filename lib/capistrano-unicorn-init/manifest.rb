module CapistranoUnicornInit
  class Manifest < ShadowPuppet::Manifest

    recipe :unicorn_config
    recipe :unicorn_master

    def unicorn_config
      file "#{configuration[:deploy_to]}/shared/config/",
        :ensure => :directory,
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :mode => '775'

      file "#{configuration[:deploy_to]}/shared/config/unicorn.rb",
        :ensure => :present,
        :content => template(File.join(File.dirname(__FILE__), '..','templates', 'unicorn.config.rb.erb')),
        :alias => "unicorn_config"
    end

    def unicorn_master
      file "#{configuration[:deploy_to]}/shared/binary/",
        :ensure => :directory,
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :mode => '775'

      file "#{configuration[:deploy_to]}/shared/binary/unicorn",
        :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'unicorn.exec'), binding),
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :mode    => '744'

      file '/etc/init.d/unicorn',
        :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'unicorn.init.erb'), binding),
        :mode    => '744'

      service 'unicorn',
        :enable  => true,
        :ensure  => :running,
        :require => file('/etc/init.d/unicorn')
    end

  end

end
