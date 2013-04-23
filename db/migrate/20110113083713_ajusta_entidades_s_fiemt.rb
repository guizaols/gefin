class AjustaEntidadesSFiemt < ActiveRecord::Migration
  def self.up
    begin
      Entidade.transaction do
        entidade = Entidade.find(:all, :conditions => ['sigla = ? AND codigo_zeus = ?', '2-642', 15])
        entidade.first.destroy

        entidade_senai = Entidade.find(:all, :conditions => ['sigla = ? AND codigo_zeus = ?', 'SENAI-DR-MT', 313])
        entidade_sesi = Entidade.find(:all, :conditions => ['sigla = ? AND codigo_zeus = ?', 'SESI-DR-MT', 213])
        entidade_senai.first.update_attributes(:nome => 'SERVIÇO NACIONAL DE APRENDIZAGEM INDUSTRIAL')
        entidade_sesi.first.update_attributes(:nome => 'SERVIÇO SOCIAL DA INDÚSTRIA')
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
    begin
      Entidade.transaction do
        entidade = Entidade.new
        entidade.id = 6
        entidade.nome = "REFRIGERAÇÃO DOMÉSTICA"
        entidade.sigla = "2-642"
        entidade.codigo_zeus = "15"
        entidade.save!
      end
    rescue Exception => e
      raise e.message
    end
  end
end
