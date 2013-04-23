class AtualizaPerfilParaEnvioAoDr < ActiveRecord::Migration
  def self.up
    AtualizaPerfilParaEnvioAoDrModel.all.each do |perfil|
      if perfil.permissao.length == 78
        if (perfil.descricao == "Master")
          AtualizaPerfilParaEnvioAoDrModel.update(perfil.id, {"permissao" => perfil.permissao + 'S'})
        else
          AtualizaPerfilParaEnvioAoDrModel.update(perfil.id, {"permissao" => perfil.permissao + 'N'})
        end
      end
    end
  end

  def self.down
    AtualizaPerfilParaEnvioAoDrModel.all.each do |perfil|
      AtualizaPerfilParaEnvioAoDrModel.update(perfil.id, {"permissao" => perfil.permissao[0..77]})
    end
  end
end

class AtualizaPerfilParaEnvioAoDrModel < ActiveRecord::Base
  set_table_name 'perfis'
end
