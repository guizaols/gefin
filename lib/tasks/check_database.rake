namespace :db do

  desc "Verifica a conexão com todos os bancos de dados"

  require 'rubygems'
  require 'activerecord'
  
  task :check do
    databases = YAML::load_file(RAILS_ROOT + '/config/database.yml')
    databases.each do |environment, settings|
      print "Testando ambiente #{environment}: "
      begin
        ActiveRecord::Base.establish_connection(settings)
        puts "OK!"
      rescue Exception => e
        puts "ERRO: #{e.message}"
      end
    end
  end
  
end
