class PlanoDeConta < ActiveRecord::Base

  acts_as_audited

  #RELACIONAMENTOS
  has_many :pagamento_de_contas, :foreign_key => 'conta_contabil_depesa_id'
  has_many :pagamento_de_contas, :foreign_key => 'conta_contabil_pessoa_id'
  has_many :parametro_conta_valores, :foreign_key => 'conta_contabil_id'
  has_many :rateios, :foreign_key => 'conta_contabil_id'
  has_many :cheques, :foreign_key => 'conta_contabil_transitoria_id'
  has_many :parcelas, :foreign_key => 'conta_contabil_desconto_id'
  has_many :parcelas, :foreign_key => 'conta_contabil_outros_id'
  has_many :parcelas, :foreign_key => 'conta_contabil_juros_id'
  has_many :parcelas, :foreign_key => 'conta_contabil_multa_id'
  has_one :contas_corrente, :foreign_key => 'conta_contabil_id'
  belongs_to :entidade

  def retorna_codigo_contabil_e_descricao
    return "#{self.codigo_contabil} - #{self.nome}"
  end

  def resumo
    "#{self.codigo_contabil} - #{self.nome}"
  end

  def self.importar_plano_de_contas(str)
    PlanoDeConta.transaction do
      entidades = {}
      contador = 0
      conversao = Iconv.conv('UTF-8', 'ISO-8859-15', str.read)
      conversao.each_line do |line|
        if line.match %r{^(\d+);(\d+);"(\d+)";"(.+)";"\d*";"[\d-]*";\d*;\d*;(\d*);"(\d*)";(\d*);(\d*)\r?$}
          entidades[$2] ||= Entidade.find_by_codigo_zeus($2).id
#          u = PlanoDeConta.find_or_initialize_by_ano_and_entidade_id_and_codigo_contabil :ano => $1,
#            :entidade_id => entidades[$2], :codigo_contabil => $3, :nome => $4, :tipo_da_conta => $5
					u = PlanoDeConta.find_by_ano_and_entidade_id_and_codigo_contabil($1, entidades[$2], $3)
					if(!u.blank?)
						u.ano = $1
						u.entidade_id = entidades[$2]
						u.codigo_contabil = $3
						u.nome = $4
						u.tipo_da_conta = $5
						u.save!
					else
						x = PlanoDeConta.new
						x.ano = $1
						x.entidade_id = entidades[$2]
						x.codigo_contabil = $3
						x.nome = $4
						x.tipo_da_conta = $5
						x.save!
					end
          #puts "Dados já existentes: #{u.inspect}" if u.id
          contador += 1
        end
      end
      if contador == 0
        [false, "Importação não realizada. Verifique o arquivo enviado!"]
      else
        [true, "Foram importados #{contador} Planos de Conta!"]
      end
    end
  end

end
