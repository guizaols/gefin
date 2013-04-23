class DefineStatusAtivoParaUsuarios < ActiveRecord::Migration
  def self.up
    begin
      Usuario.transaction do
        SetaStatusParaUsuarios.all.each do |usuario|
          usuario.status = Usuario::ATIVO
          usuario.save!
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
    begin
      Usuario.transaction do
        SetaStatusParaUsuarios.all.each do |usuario|
          usuario.status = nil
          usuario.save!
        end
      end
    rescue Exception => e
      raise e.message
    end
  end
end

class SetaStatusParaUsuarios < ActiveRecord::Base
  set_table_name 'usuarios'
end
