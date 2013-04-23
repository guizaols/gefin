class GeraServicoCoringa < ActiveRecord::Migration

  def self.up
    Unidade.all.each do |unidade|
      servico = Servico.new({:unidade => unidade, :descricao => "Serviço Importação", :ativo => true,
          :modalidade => "Modalidade Importação", :codigo_do_servico_sigat => "99999"})
      servico.save!
    end

    AtualizaServicoEmRecebimentoDeConta.all.each do |recebimento|
      if Servico.find_by_id(recebimento.servico_id).blank?
        servico_contrato = Servico.find_by_unidade_id_and_descricao(recebimento.unidade_id, 'Serviço Importação')
        AtualizaServicoEmRecebimentoDeConta.update(recebimento.id, {"servico_id" => servico_contrato.id})
      end
    end
  end

  def self.down
    Servico.all.each do |servico|
      if servico.descricao == 'Serviço Importação'
        servico.destroy
      end
    end
    AtualizaServicoEmRecebimentoDeConta.all.each do |recebimento|
      if Servico.find_by_id(recebimento.servico_id).blank?
        AtualizaServicoEmRecebimentoDeConta.update(recebimento.id, {"servico_id" => nil})
      end
    end
  end

end

class AtualizaServicoEmRecebimentoDeConta < ActiveRecord::Base
  set_table_name 'recebimento_de_contas'
end
