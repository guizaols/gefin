#CorrigeDataCancelamento
class IndexDatabase < ActiveRecord::Migration
  def self.up
    begin
      RecebimentoDeConta.transaction do
        string = "Contrato cancelado em".formatar_para_like
        historicos = HistoricoOperacao.find(:all, :conditions => ['descricao LIKE ?', string])
        if !historicos.blank?
          historicos.each do |historico|
            contrato = RecebimentoDeConta.find_by_id(historico.conta_id)            
            contrato.data_cancelamento = historico.created_at
            contrato.save false
          end
        end
        string = "Contrato abdicado em".formatar_para_like
        historicos = HistoricoOperacao.find(:all, :conditions => ['descricao LIKE ?', string])
        if !historicos.blank?
          historicos.each do |historico|
            contrato = RecebimentoDeConta.find_by_id(historico.conta_id)
            contrato.data_cancelamento = historico.created_at
            contrato.save false
          end
        end
        string = "Contrato evadido em".formatar_para_like
        historicos = HistoricoOperacao.find(:all, :conditions => ['descricao LIKE ?', string])
        if !historicos.blank?
          historicos.each do |historico|
            contrato = RecebimentoDeConta.find_by_id(historico.conta_id)            
            contrato.data_evasao = historico.created_at
            contrato.data_registro_evasao = historico.created_at
            contrato.save false
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
    begin
      RecebimentoDeConta.transaction do
        string = "Contrato cancelado em".formatar_para_like
        historicos = HistoricoOperacao.find(:all, :conditions => ['descricao LIKE ?', string])
        if !historicos.blank?
          historicos.each do |historico|
            contrato = RecebimentoDeConta.find_by_id(historico.conta_id)
            contrato.data_cancelamento = nil
            contrato.save false
          end
        end
        string = "Contrato abdicado em".formatar_para_like
        historicos = HistoricoOperacao.find(:all, :conditions => ['descricao LIKE ?', string])
        if !historicos.blank?
          historicos.each do |historico|
            contrato = RecebimentoDeConta.find_by_id(historico.conta_id)
            contrato.data_cancelamento = nil
            contrato.save false
          end
        end
        string = "Contrato evadido em".formatar_para_like
        historicos = HistoricoOperacao.find(:all, :conditions => ['descricao LIKE ?', string])
        if !historicos.blank?
          historicos.each do |historico|
            contrato = RecebimentoDeConta.find_by_id(historico.conta_id)            
            contrato.data_evasao = nil
            contrato.data_registro_evasao = nil
            contrato.save false
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end
end
