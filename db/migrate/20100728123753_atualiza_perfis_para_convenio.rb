class AtualizaPerfisParaConvenio < ActiveRecord::Migration
  def self.up
    AtualizaPerfilParaConvenio.all.each do |perfil|
      if perfil.permissao.length == 70
        if (perfil.descricao == "Master")
          AtualizaPerfilParaConvenio.update(perfil.id, {"permissao" => perfil.permissao + 'SS'})
        else
          AtualizaPerfilParaConvenio.update(perfil.id, {"permissao" => perfil.permissao + 'NN'})
        end
      end
    end
  end

  def self.down
    AtualizaPerfilParaConvenio.all.each do |perfil|
      AtualizaPerfilParaConvenio.update(perfil.id, {"permissao" => perfil.permissao[0..69]})
    end
  end
end

class AtualizaPerfilParaConvenio < ActiveRecord::Base
  set_table_name 'perfis'
end
