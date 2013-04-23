class CorrigiContratosEvadidos < ActiveRecord::Migration
  def self.up
     begin
      RecebimentoDeConta.transaction do
        contratos = RecebimentoDeConta.find(:all, :conditions => ['data_evasao IS NOT NULL'])
        if !contratos.blank?
          contratos.each do |contrato|
            #contrato.situacao = RecebimentoDeConta::Evadido if contrato.situacao == RecebimentoDeConta::Normal
            contrato.situacao_fiemt = RecebimentoDeConta::Evadido if contrato.situacao_fiemt == RecebimentoDeConta::Normal
            contrato.save false
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
  end
end
