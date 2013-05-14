# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION
#
# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  #  config.gem 'rack'
  #  config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  #  config.gem "aws-s3", :lib => "aws/s3"
  #  config.gem "rspec-rails", :lib => "spec"

  config.gem 'rghost'
  config.gem 'rghost_barcode'
  config.gem 'parseline'
  #config.gem 'thin'
  #config.gem "pdfkit"

  #config.middleware.use "PDFKit::Middleware", :print_media_type => true

  if RUBY_PLATFORM.include? 'linux'
    #config.gem 'dbi', :version => '0.4.0'
    #config.gem 'dbd-odbc', :version => '0.2.4', :lib => 'dbd/ODBC'
    #config.gem 'rails-sqlserver-2000-2005-adapter', :source => 'http://gems.github.com'
  end
  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.

  config.time_zone = 'Brasilia'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_modelo_session',
    :secret      => '41614c43cc0aa0b2cb49c52d0cb8fb0333f20c12972b78dec3b26a88dc45dcb3d2912be4805f59e4602f84c3ff11460d5f48caaad7a2c177ac4ece23d19b32e5'
  }

  config.load_paths << "#{RAILS_ROOT}/vendor/prawn/lib"
  config.load_paths << "#{RAILS_ROOT}/vendor/prawn-labels/lib"

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end

if RAILS_ENV == 'production'
  RGhost::Config::GS[:path] = 'C:\\Program Files\\gs\\gs9.02\\bin\\gswin32c.exe'
else
  RGhost::Config::GS[:path] = 'C:\\Program Files\\gs\\gs9.02\\bin\\gswin32c.exe'
end

require 'brazilian-rails'
require 'brI18n'
require '_libs'
require 'prawn/core'
require 'prawn/labels'
require 'brcobranca'
require 'audit_plus'

#class Array
#  def retorna_itens_duplicados_do_vetor(*v)
#    v.group_by{|e| e}.reject{|e| e.last.length == 1}.collect(&:first)
#  end
#end

class Logger
  def erro(message, exception = nil)
    error Time.now.to_s(:db)+" "+message
    if exception
      error "Message: #{exception.message}"
      error 'Backtrace:'
      error exception.backtrace.join("\n")
    end
  end
end

class String
  def formatar_para_like
    if self.include? '*'
      self.gsub('*', '%')
    else
      "%" + self + "%"
    end
  end
end

class NilClass
  def formatar_para_like
    '%'
  end
end



LANCAMENTOS_LOGGER = Logger.new(RAILS_ROOT + "/log/lancamentos_#{RAILS_ENV}.log", 10, 100000000)

I18n.reload!
ExceptionNotifier.exception_recipients = %w(paulovitorzeferino@gmail.com)

ActionMailer::Base.smtp_settings = {
   :address => "smtp.gmail.com",
   :port => 587,
   :domain => "devconnit.com",
   :user_name => "no-reply@devconnit.com",
   :password => "no-reply#135792468",
   :authentication => :plain,
   :enable_starttls_auto => true
}

#ActionMailer::Base.smtp_settings = {
#  :address => 'mail.inovare.net',
#  :port => '25',
#  :user_name => 'no-reply@inovare.net',
#  :password => 'inovare1105',
#  :authentication => :login
#}

class ActiveRecord::Base

  def self.human_attribute_name(attr)
    self::HUMANIZED_ATTRIBUTES[attr.to_sym] || attr.humanize
  end

end

module ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods

  def new_window_to(location)
    url = location.is_a?(String) ? location : @context.url_for(location)
    record "window.open(#{url.inspect});"
  end

end
