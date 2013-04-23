class InsereEntidadesNoBanco < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO entidades(nome,sigla,codigo_zeus) VALUES('FEDERAÇÃO DAS INDÚSTRIAS NO ESTADO DE MT','FIEMT',513)"
    execute "INSERT INTO entidades(nome,sigla,codigo_zeus) VALUES('SERVIÇO NACIONAL DE APRENDIZAGEM INDUSTRIA NO MT','SENAI-DR-MT',313)"
    execute "INSERT INTO entidades(nome,sigla,codigo_zeus) VALUES('SERVIÇO SOCIAL DA INDÚSTRIA NO ESTADO DE MT','SESI-DR-MT',213)"
    execute "INSERT INTO entidades(nome,sigla,codigo_zeus) VALUES('INSTITUTO EUVALDO LODI','IEL',413)"
    execute "INSERT INTO entidades(nome,sigla,codigo_zeus) VALUES('CONDOMÍNIO CASA DA INDÚSTRIA NO ESTADO DE MT','CONDOMINIO',613)"
    execute "INSERT INTO entidades(nome,sigla,codigo_zeus) VALUES('REFRIGERAÇÃO DOMÉSTICA','2-642',15)"
  end

  def self.down
  end
end
