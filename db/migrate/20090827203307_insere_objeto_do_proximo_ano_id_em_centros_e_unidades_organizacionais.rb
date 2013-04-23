class InsereObjetoDoProximoAnoIdEmCentrosEUnidadesOrganizacionais < ActiveRecord::Migration
  def self.up
     add_column :centros , :objeto_do_proximo_ano_id, :integer
     add_column :unidade_organizacionais, :objeto_do_proximo_ano_id, :integer
  end

  def self.down
     remove_column :centros , :objeto_do_proximo_ano_id
     remove_column :unidade_organizacionais, :objeto_do_proximo_ano_id
  end
  
end
