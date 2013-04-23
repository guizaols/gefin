class AtualizarPerfis < ActiveRecord::Migration
  def self.up
    AtualizaPerfil.all.each do |perfil|
      if perfil.permissao.length == 46
        if (perfil.descricao == "Master") || (perfil.descricao == "Contador")
          AtualizaPerfil.update(perfil.id, {"permissao" => perfil.permissao + 'SS'})
        else
          AtualizaPerfil.update(perfil.id, {"permissao" => perfil.permissao + 'NN'})
        end
      end
    end
  end

  def self.down
    AtualizaPerfil.all.each do |perfil|
      AtualizaPerfil.update(perfil.id, {"permissao" => perfil.permissao[0..45]})
    end
  end
end

class AtualizaPerfil < ActiveRecord::Base
  set_table_name 'perfis'
end
