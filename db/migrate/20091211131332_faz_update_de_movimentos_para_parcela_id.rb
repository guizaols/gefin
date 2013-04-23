class FazUpdateDeMovimentosParaParcelaId < ActiveRecord::Migration
  def self.up
    movimentos = AtualizaMovimento.find(:all, :conditions => ['((movimentos.numero_da_parcela IS NOT NULL) AND (movimentos.conta_id IS NOT NULL) AND (movimentos.conta_type IS NOT NULL))'])
    AtualizaMovimento.transaction do
      movimentos.each do |mov|
        parcela = AtualizaParcela.find_by_conta_id_and_conta_type_and_numero(mov.conta_id, mov.conta_type, mov.numero_da_parcela)
        unless parcela.blank?
          mov.parcela_id = parcela.id
          mov.save!
        else
          raise("Problemas com parcelas no movimento cujo ID é: #{mov.id}!")
        end
      end
    end
  end

  def self.down
    AtualizaMovimento.all.each do |mov|
      mov.parcela_id = nil
      mov.save!
    end
  end

  class AtualizaMovimento < ActiveRecord::Base
    set_table_name 'movimentos'
  end

  class AtualizaParcela < ActiveRecord::Base
    set_table_name 'parcelas'
  end

end
