class CorrigeMovimentosDeContabilizacao < ActiveRecord::Migration

  def self.up
    begin
      Movimento.transaction do
        AtualizaMovimentosDeContabilizacao.find(:all, :conditions => ['lancamento_inicial = ?', true]).each do |movimento|
          recebimento = RecebimentoDeConta.find_by_id(movimento.conta_id)
          if !recebimento.blank?
            if movimento.destroy
              ano = recebimento.ano
              data = recebimento.data_inicio
              centro = Centro.first(:conditions => ["(codigo_centro LIKE ?) AND (ano = ?) AND (entidade_id = ?)", '9%', ano, recebimento.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
              unidade_organizacional = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional LIKE ?) AND (ano = ?) AND (entidade_id = ?)", '9%', ano, recebimento.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

              lancamento_debito = [{:tipo => "D", :unidade_organizacional => unidade_organizacional,
                  :plano_de_conta => recebimento.unidade.parametro_conta_valor_cliente(ano).conta_contabil,
                  :centro => centro, :valor => recebimento.valor_do_documento}]
              lancamento_credito = [{:tipo => "C", :unidade_organizacional => unidade_organizacional,
                  :plano_de_conta => recebimento.unidade.parametro_conta_valor_faturamento(ano).conta_contabil,
                  :centro => centro, :valor => recebimento.valor_do_documento}]

              Movimento.lanca_contabilidade(ano, [
                  {:conta => recebimento,
                    :historico => recebimento.historico,
                    :numero_de_controle => recebimento.numero_de_controle,
                    :data_lancamento => data,
                    :tipo_lancamento => "S",
                    :tipo_documento => recebimento.tipo_de_documento,
                    :provisao => Movimento::PROVISAO,
                    :pessoa_id => recebimento.pessoa_id,
                    :lancamento_inicial => true},
                  lancamento_debito, lancamento_credito], recebimento.unidade_id)
            else
              raise("Não foi possível excluir o movimento \n\n#{movimento.errors.full_messages.join("\n")}")
            end
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
    begin
      Movimento.transaction do
        AtualizaMovimentosDeContabilizacao.find(:all, :conditions => ['lancamento_inicial = ?', true]).each do |movimento|
          recebimento = RecebimentoDeConta.find_by_id(movimento.conta_id)
          if !recebimento.blank?
            if movimento.destroy
              data = recebimento.data_inicio
              ano = recebimento.ano
              centro = Centro.first(:conditions => ["(codigo_centro LIKE ?) AND (ano = ?) AND (entidade_id = ?)", '9%', ano, recebimento.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
              unidade_organizacional = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional LIKE ?) AND (ano = ?) AND (entidade_id = ?)", '9%', ano, recebimento.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

              #INVERTENDO
              lancamento_credito = [{:tipo => "C", :unidade_organizacional => unidade_organizacional,
                  :plano_de_conta => recebimento.unidade.parametro_conta_valor_cliente(ano).conta_contabil,
                  :centro => centro, :valor => recebimento.valor_do_documento}]
              lancamento_debito = [{:tipo => "D", :unidade_organizacional => unidade_organizacional,
                  :plano_de_conta => recebimento.unidade.parametro_conta_valor_faturamento(ano).conta_contabil,
                  :centro => centro, :valor => recebimento.valor_do_documento}]

              Movimento.lanca_contabilidade(ano, [
                  {:conta => recebimento,
                    :historico => "Contrato #{recebimento.numero_de_controle} gerado.",
                    :numero_de_controle => recebimento.numero_de_controle,
                    :data_lancamento => data,
                    :tipo_lancamento => "S",
                    :tipo_documento => recebimento.tipo_de_documento,
                    :provisao => Movimento::PROVISAO,
                    :pessoa_id => recebimento.pessoa_id,
                    :lancamento_inicial => true},
                  lancamento_debito, lancamento_credito], recebimento.unidade_id)
            else
              raise("Não foi possível excluir o movimento \n\n#{movimento.errors.full_messages.join("\n")}")
            end
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end
end

class AtualizaMovimentosDeContabilizacao < ActiveRecord::Base
  set_table_name 'movimentos'
end