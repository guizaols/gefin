class CorrigeAlteracaoCentroUnidadeDevidoAoProblemaDoRateio < ActiveRecord::Migration
  def self.up
    begin
      RecebimentoDeConta.transaction do
        conta_contabil_41010407005 = PlanoDeConta.find(:first, :conditions => ['entidade_id = 3 AND codigo_contabil = ? AND ano = ?', '41010407005', '2012'])
        conta_contabil_41010407006 = PlanoDeConta.find(:first, :conditions => ['entidade_id = 3 AND codigo_contabil = ? AND ano = ?', '41010407006', '2012'])
        recebimentos = RecebimentoDeConta.find(:all, :conditions => [
            'unidade_id = ? AND (contabilizacao_da_receita IS NULL OR contabilizacao_da_receita = ?) AND 
             YEAR(data_inicio_servico) = ? AND MONTH(data_inicio_servico) = ? AND conta_contabil_receita_id IN (?)',
            '9', '0', '2012', '2', [conta_contabil_41010407005.id, conta_contabil_41010407006.id]
          ])
        recebimentos.each do |contrato|
          contrato.parcelas.each do |parcela|
            if parcela.rateios.length > 1
              parcela.rateios.each do |rateio|
                rateio.centro_id = contrato.centro_id
                rateio.unidade_organizacional_id = contrato.unidade_organizacional_id
                rateio.save false
              end
            end
          end
        end
      end
    rescue Exception => e
      p e.message
    end
  end

  def self.down
  end
end
