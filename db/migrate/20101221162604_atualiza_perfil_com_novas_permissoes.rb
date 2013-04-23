class AtualizaPerfilComNovasPermissoes < ActiveRecord::Migration
  def self.up
    begin
      Perfil.transaction do
        AtualizarPerfil.all.each do |perfil|
          if perfil.permissao.length == 87
            if (perfil.descricao == "Master")
              AtualizarPerfil.update(perfil.id, {"permissao" => perfil.permissao + 'SSS'})
            else
              AtualizarPerfil.update(perfil.id, {"permissao" => perfil.permissao + 'NNN'})
            end
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
    AtualizarPerfil.all.each do |perfil|
      AtualizarPerfil.update(perfil.id, {"permissao" => perfil.permissao[0..86]})
    end
  end
end

class AtualizarPerfil < ActiveRecord::Base
  set_table_name 'perfis'
end
