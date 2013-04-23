class ImportarLocalidades < ActiveRecord::Migration
  def self.up
    Entidade.importar_localidades_do_gefin
  end

  def self.down
    execute("delete from localidades")
  end
end
