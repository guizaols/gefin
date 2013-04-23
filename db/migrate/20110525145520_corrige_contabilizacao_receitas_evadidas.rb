class CorrigeContabilizacaoReceitasEvadidas < ActiveRecord::Migration
  def self.up
#    begin
#      RecebimentoDeConta.transaction do
#        numeros_de_controle = ['SECBA-CTR12/100677', 'SECBA-CTR01/110115', 'SECBA-CTR01/110137', 'SECBA-CTR01/110066',
#          'SECBA-CTR12/101050', 'SECBA-CTR12/100631', 'SECBA-CTR12/100924', 'SECBA-CTR12/100819', 'SECBA-CTR12/100552',
#          'SECBA-CTR12/100512', 'SECBA-CTR12/100524', 'SECBA-CTR12/100562', 'SECBA-CTR02/110010', 'SECBA-CTR12/100527',
#          'SECBA-CTR12/100573', 'SECBA-CTR12/100718', 'SECBA-CTR01/110211', 'SECBA-CTR12/100513', 'SECBA-CTR12/100742',
#          'SECBA-CTR01/110029']
#
#        numeros_de_controle.each do |numero|
#          conta = RecebimentoDeConta.find_by_numero_de_controle(numero)
#          if conta && !conta.data_evasao.blank?
#            movimentos = Movimento.find_all_by_conta_id(conta.id)
#            movimentos.each do |mov|
#              if mov.tipo_lancamento == 'C' && mov.data_lancamento.to_date > "31/03/2011".to_date#conta.data_evasao.to_date
#                p "#{conta.numero_de_controle} - #{mov.valor_total}"
#                #mov.destroy || raise("Não foi possível remover o movimento com ID: #{mov.id}")
#              end
#            end
#          end
#        end
#      end
#    rescue Exception => e
#      raise e.message
#    end
  end

  def self.down
  end

end
