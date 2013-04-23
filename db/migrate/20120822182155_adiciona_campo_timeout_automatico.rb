class AdicionaCampoTimeoutAutomatico < ActiveRecord::Migration
  def self.up
  	add_column :unidades,:tempo_sessao,:integer
  	Unidade.all.each do |unidade|
  		unidade.tempo_sessao = 40
  		unidade.save!
  	end 
  end

  def self.down
  	remove_column :unidades,:tempo_sessao
  end
end
