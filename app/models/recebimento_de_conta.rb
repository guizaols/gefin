class RecebimentoDeConta < ActiveRecord::Base
  extend BuscaExtendida
  include ContaPagarReceber

  acts_as_audited

  NAO = 0
  SIM = 1

  Interna = 0
  Externa = 1

  Normal = 1
  Cancelado = 2
  Juridico = 3
  Renegociado = 4
  Inativo = 5
  Permuta = 6
  Baixa_do_conselho = 7
  Desconto_em_folha = 8
  Enviado_ao_DR = 9
  Devedores_Duvidosos_Ativos = 10
  Evadido = 11
  PARAMS_PROJECAO = nil

  OPCOES_SITUACAO_PARA_COMBO = [
    ['Normal', Normal], ['Baixa do conselho', Baixa_do_conselho], ['Cancelado', Cancelado],
    ['Desconto em Folha', Desconto_em_folha], ['Inativo', Inativo], ['Jurídico', Juridico],
    ['Permuta', Permuta], ['Renegociado', Renegociado],
    ['Enviado ao DR', Enviado_ao_DR], ['Perdas no Recebimento de Créditos - Clientes', Devedores_Duvidosos_Ativos]
  ]
  OPCOES_SITUACAO_PARA_COMBO_ALTERAR_STATUS = [
    ['Normal', Normal], ['Baixa do conselho', Baixa_do_conselho], ['Cancelado', Cancelado],
    ['Desconto em Folha', Desconto_em_folha], ['Jurídico', Juridico], ['Permuta', Permuta]
  ]
  HASH_ORDENACAO = {'unidade_organizacionais.codigo_da_unidade_organizacional' => 'Unidade Organizacional',
    'centros.codigo_centro' => 'Centro', 'plano_de_contas.codigo_contabil' => 'Conta Contábil',
    'servicos.descricao' => 'Serviço', 'pessoas.nome' => 'Cliente'}

  CARTA_1 = 1
  CARTA_2 = 2
  CARTA_3 = 3

  DR = 1
  TERCEIRIZADA = 2

  ETIQUETAS = {
    "A4263" => {:linha => 6, :coluna => 1},
    "6080" => {:linha => 9, :coluna => 2},
    "6081" => {:linha => 9, :coluna => 1},
    "6082" => {:linha => 6, :coluna => 1},
    "6083" => {:linha => 4, :coluna => 1},
  }

  #RELACIONAMENTOS
  has_one :recebimento_de_conta_filha, :class_name => 'RecebimentoDeConta', :foreign_key => 'recebimento_de_conta_mae_id'
  has_many :reajustes, :class_name => 'Reajuste', :foreign_key => 'conta_id'
  belongs_to :recebimento_de_conta_mae, :class_name => 'RecebimentoDeConta'
  belongs_to :dependente
  belongs_to :servico
  belongs_to :conta_contabil_receita, :class_name => 'PlanoDeConta'
  belongs_to :vendedor, :class_name => 'Pessoa'
  belongs_to :cobrador, :class_name => 'Pessoa'
  belongs_to :usuario_renegociacao, :class_name => 'Usuario'

  #VALIDAÇÕES
  validates_presence_of :servico, :data_inicio, :conta_contabil_receita, :data_venda, :vigencia, :data_final_servico, :data_inicio_servico
  validates_numericality_of :dia_do_vencimento, :greater_than => 0, :less_than => 32
  validates_numericality_of :multa_por_atraso, :juros_por_atraso, :greater_than_or_equal_to => 0
  validates_inclusion_of :origem, :in => [Interna, Externa]
  validates_inclusion_of :provisao, :in => [SIM, NAO]
  validates_inclusion_of :situacao, :in => [Normal, Cancelado, Juridico, Renegociado, Inativo]
  validates_inclusion_of :situacao_fiemt, :in => [Normal, Cancelado, Renegociado, Juridico, Permuta, Baixa_do_conselho, Inativo, Desconto_em_folha, Devedores_Duvidosos_Ativos, Evadido]
  validates_presence_of :vendedor, :if => Proc.new{|r| r.origem == Interna }
  validates_numericality_of :vigencia, :greater_than => 0, :message => 'deve ser maior do que zero.'

  #FORMATAÇÕES E ATRIBUTOS
  data_br_field :data_inicio, :data_venda, :data_final, :data_final_servico, :data_inicio_servico, :data_cancelamento,
		:data_evasao, :data_registro_evasao
  converte_para_data_para_formato_date :data_inicio, :data_final, :data_venda, :data_primeira_carta,
		:data_segunda_carta, :data_terceira_carta, :data_final_servico, :data_inicio_servico, :data_cancelamento,
		:data_evasao, :data_registro_evasao, :data_reversao, :data_reversao_evasao 
  attr_writer :dados_parcela
  attr_accessor :renegociando, :inserindo_nova_parcela, :ano_contabil_atual, :atualizando_parcelas,
		:cancelando_parcela, :parando_servico, :mensagem_de_erro, :vincular_carta, :evadindo, :lancando_inicialmente,
		:abdicando, :prorrogando, :iniciando_servicos, :revertendo, :revertendo_evasao
  attr_reader :mes_venda
  attr_protected :data_final, :situacao, :dados_parcela
  cria_readers_e_writers_para_o_nome_dos_atributos :servico, :conta_contabil_receita, :vendedor, :cobrador, :dependente
  serialize :historico_projecoes

  HUMANIZED_ATTRIBUTES = {
    :data_inicio => "O campo data de início",
    :vendedor => "O campo vendedor",
    :vigencia => "O campo vigência",
    :numero_de_parcelas=>"O campo número de parcelas",
    :conta_contabil_receita=>"O campo conta contábil receita",
    :origem => "O campo origem",
    :dia_do_vencimento => "O campo dia do vencimento",
    :servico => "O campo servico",
    :dependente  => "O campo dependente",
    :pessoa => "O campo pessoa",
    :data_final => "O campo data final",
    :data_venda => "O campo data venda",
    :situacao => "O campo situação",
    :cobrador => "O campo cobrador",
    :situacao_fiemt => "O campo situacao FIEMT",
    :centro => 'O campo centro',
    :historico => 'O campo histórico',
    :rateio => 'O campo rateio',
    :numero_nota_fiscal => 'O campo número da nota fiscal',
    :tipo_de_documento => 'O campo tipo de documento',
    :valor_do_documento => 'O campo valor',
    :unidade_organizacional => 'O campo unidade organizacional',
    :data_final_servico => "O Campo Data Final do Serviço",
    :data_inicio_servico => "O Campo Data Inicial do Serviço",
    :provisao => "O Campo Provisão"
  }

  def initialize(params = {})
    params[:data_inicio] ||= Date.today
    params[:data_venda] ||= Date.today
    params[:multa_por_atraso] ||= 2
    params[:juros_por_atraso] ||= 1
    super
    self.parcelas_geradas = false
    self.inserindo_nova_parcela = false
    self.atualizando_parcelas = false
    self.cancelando_parcela = false
    self.situacao = Normal
    self.numero_de_renegociacoes = 0
    self.situacao_fiemt = Normal
    self.servico_iniciado = false
		self.vincular_carta = false
    self.renegociando = false
    self.evadindo = false
    self.lancando_inicialmente = false
    self.abdicando = false
		self.prorrogando = false
    self.iniciando_servicos = false
    self.revertendo = false
    self.revertendo_evasao = false
  end

  def validate_on_create
    unless(self.pessoa.liberado_pelo_dr || !self.pessoa.tem_parcelas_atrasadas?)
      cliente = self.pessoa.fisica? ? self.pessoa.nome.upcase : self.pessoa.razao_social.upcase
      unidades = self.pessoa.unidade_parcelas_atrasadas
      errors.add :base, "O cliente #{cliente} possui parcelas atrasadas #{unidades} e por isso não pode ter outro contrato cadastrado. Solicite ao gerente a liberação."
     end if(self.pessoa)
  end

  def after_update
    if !self.renegociando && self.projetando != true && (self.numero_de_parcelas_changed? || self.valor_do_documento_changed?) && !(self.inserindo_nova_parcela || self.cancelando_parcela || self.atualizando_parcelas)
      #    if (self.numero_de_parcelas_changed? || self.valor_do_documento_changed?) && !(self.inserindo_nova_parcela || self.cancelando_parcela || self.atualizando_parcelas)
      self.parcelas.each{|parcela| parcela.destroy if parcela.verifica_situacoes}
      self.movimentos.each{|movimento| movimento.destroy} unless self.parcelas.each{|item| item.situacao == Parcela::QUITADA}
      self.gerar_parcelas(ano_contabil_atual)
    end
  end

  def before_destroy
    if self.alguma_parcela_baixada? && self.parcelas.length > 0
      self.mensagem_de_erro = 'O contrato não pode ser excluído porque possuir uma ou mais parcelas com a situação Quitada!'
      return false
    end
    if self.liberacao_dr_faixa_de_dias_permitido != true && self.parcelas.length > 0
      if !validar_data_inicio && !validar_data_inicio_entre_limites
        self.mensagem_de_erro = 'Não foi possível excluir o contrato, pois a data de início excedeu o limite máximo permitido'
        return false
      end
    end
  end
  
  def destroy_contrato
    if self.parcelas.length == 0
      self.movimentos.each{|mov| mov.destroy} if self.provisao == SIM
      self.destroy
    else
      false
    end
  end

  def origem_verbose
    case origem
    when Interna; 'Interna'
    when Externa; 'Externa'
    end
  end

  def servico_iniciado?
    self.servico_iniciado
  end

  def servico_nao_iniciado?
    !self.servico_iniciado
  end

  def servico_nunca_iniciado?
    !self.servico_alguma_vez_iniciado
  end

  def servico_iniciado_verbose
    if servico_iniciado?
      "Sim"
    else
      "Não"
    end
  end

  def dados_parcela
    unless @dados_parcela
      @dados_parcela = {}
      contador = 1
      self.parcelas.each do |parcela|
        id_da_parcela = parcela.id.to_s
        @dados_parcela[id_da_parcela] ||= {}
        @dados_parcela[id_da_parcela]["valor"] ||= parcela.valor
        @dados_parcela[id_da_parcela]["data_vencimento"] ||= parcela.data_vencimento
        @dados_parcela[id_da_parcela]["situacao"] ||= parcela.situacao
        @dados_parcela[id_da_parcela]["situacao_verbose"] ||= parcela.situacao_verbose
        @dados_parcela[id_da_parcela]["numero"] ||= parcela.numero
        contador +=1
      end
    end
    @dados_parcela
  end

  def situacao_verbose
    situacao_verbose = case situacao
    when Normal; 'Normal'
    when Externa; 'Externa'
    when Cancelado; 'Cancelado'
    when Juridico; 'Jurídico'
    when Renegociado; 'Renegociado'
    when Inativo; 'Inativo'
    when Evadido; 'Evadido'
    end
    situacao_verbose
  end

  def situacao_fiemt_verbose(situacao = nil)
    situacao = situacao_fiemt if !situacao
    situacao_fiemt_verbose = case situacao
    when Normal; 'Normal'
    when Juridico; 'Jurídico'
    when Renegociado; 'Renegociado'
    when Inativo; 'Inativo'
    when Permuta; 'Permuta'
    when Baixa_do_conselho; 'Baixa do Conselho'
    when Desconto_em_folha; 'Desconto em Folha'
    when Enviado_ao_DR; 'Enviado ao DR'
    when Devedores_Duvidosos_Ativos; 'Perdas no Recebimento de Créditos - Clientes'
	  when Cancelado; 'Cancelado'
    when Evadido; 'Evadido'
    end
    situacao_fiemt_verbose
  end

  def situacoes
    retorno = [situacao_verbose]
    (retorno << situacao_fiemt_verbose) if situacao_fiemt != Normal
    retorno.join(" / ")
  end

  def before_validation
    calcula_data_final
  end

  def calcula_data_final
    if data_inicio && vigencia && vigencia > 0
      self.data_final = data_inicio.to_date + vigencia.months
    end
  end

  def validate
    errors.add :historico, 'não pode ser possuir um valor com mais de 254 caracteres' if tamanho_campo_historico
    errors.add :base, 'Não é possível alterar o nome do cliente, pois este contrato já possui parcelas baixadas' if nao_pode_alterar_dados_do_cliente_em_contrato?
    errors.add :conta_contabil_receita, 'Conta Contábil de Receita inválida, selecione uma conta sintética' if self.conta_contabil_receita && self.conta_contabil_receita.tipo_da_conta == 0
    errors.add :dependente, 'pertence a outro cliente' if pessoa && dependente && !pessoa.dependentes.include?(dependente)
    errors.add :servico, 'pertence a outra unidade' if servico && unidade && servico.unidade != unidade
    errors.add :vendedor, 'não é funcionário' if vendedor && !vendedor.funcionario?
    errors.add :cobrador, 'não é funcionário' if cobrador && !cobrador.funcionario?
    errors.add :valor_do_documento, 'não pode ser alterado porque o contrato está cancelado.' if self.valor_do_documento_changed? && self.situacao == Cancelado
    errors.add :situacao, 'do contrato é cancelado.' if self.situacao_was == Cancelado && self.cancelado_pela_situacao_fiemt_was != true
    
p (Date.today - self.data_inicio_servico.to_date).days.to_i rescue nil
   # errors.add :data_inicio_servico, 'não pode ter mês diferente do mês vigente' if !self.data_inicio_servico.blank? && (( self.data_inicio_servico.to_date + self.unidade.lancamentoscontasreceber) < Date.today ) && self.new_record?


    unless self.new_record?
      if self.alguma_parcela_baixada?
        errors.add :rateio, 'não pode ser alterado após alguma parcela ser baixada.' if self.rateio_changed?
      end
      errors.add :provisao, 'não pode ser alterado após o registro do contrato.' if self.provisao_changed?
    end
    if self.numero_de_renegociacoes_changed?
      errors.add :base, 'Para efetuação da renegociação, deve ser alterado o campo número da parcela ou o campo valor.' if (self.numero_de_parcelas_changed? == false) && (self.valor_do_documento_changed? == false)
    end
    

    if self.liberacao_dr_faixa_de_dias_permitido != true && !self.prorrogando && !self.evadindo && !self.abdicando &&
        !self.iniciando_servicos && !self.cancelando_parcela && !self.revertendo && !self.revertendo_evasao
      if !validar_data_inicio && !validar_data_inicio_entre_limites
        errors.add :data_inicio, 'excedeu o limite máximo permitido.' unless self.vincular_carta
      end
    end
    #errors.add :situacao_fiemt, "não pode ser modificado por estar como #{situacao_fiemt_verbose(situacao_fiemt_was)}" if (situacao_fiemt_was == Enviado_ao_DR || situacao_fiemt_was == Devedores_Duvidosos_Ativos)

    if self.data_inicio.to_date > Date.today
      errors.add :base, 'Não podem ser efetuados lançamentos com datas futuras'
    end



    if !data_final_servico.blank? && !data_inicio_servico.blank?
      errors.add :base, 'A data inicial do serviço deve ser menor que a data final do serviço.' if data_final_servico.to_date < data_inicio_servico.to_date
    end
    if self.provisao == SIM && self.lancando_inicialmente
      unless self.unidade.blank?
        errors.add :base, 'Deve ser parametrizada uma conta contábil do tipo Cliente.' if self.unidade.parametro_conta_valor_cliente(self.ano_contabil_atual).blank?
        errors.add :base, 'Deve ser parametrizada uma conta contábil do tipo Faturamento.' if self.unidade.parametro_conta_valor_faturamento(self.ano_contabil_atual).blank?
      end
    end
  end

  def nao_pode_alterar_dados_do_cliente_em_contrato?
    if !self.new_record? && self.alguma_parcela_baixada? && self.pessoa_id_changed?
      true #Quando não for um novo registro e já tiver parcela baixada não pode alterar o nome do cliente
    else
      false
    end
  end

  def before_save
    if self.nao_permite_alteracao? && !self.abdicando && !self.evadindo
      errors.add :base, 'Este contrato não pode ser modificado pois encontra-se cancelado'
    end
    #  self.valor_origal = self.valor_do_documento unless servico_iniciado || parando_servico
  end

  def after_create
    HistoricoOperacao.cria_follow_up("Conta a receber criada", @usuario_corrente, self, nil , nil, self.valor_do_documento)
    if(self.pessoa && self.pessoa.liberado_pelo_dr)
      self.pessoa.liberado_pelo_dr = false
      self.pessoa.save
    end
  end

  def destroy_lancamento!
		begin
			Movimento.transaction do
				movimentos = Movimento.find(:all, :conditions => {:lancamento_inicial => true, :conta_id => self.id, :parcela_id => nil})
				unless movimentos.blank?
					movimentos.each do |movimento|
						movimento.destruindo = true
						movimento.destroy
						movimento.destruindo = false
					end
				end
			end
		rescue Exception => e
			p e
		end
	end

	def efetua_lancamento!
		data = self.data_inicio
		centro = Centro.first(:conditions => ['(codigo_centro LIKE ?) AND (ano = ?) AND (entidade_id = ?)', '9%', self.ano, self.unidade.entidade_id]) || raise('Não existe um Centro de Responsabilidade Empresa válido')
		unidade_organizacional = UnidadeOrganizacional.first :conditions => ['(codigo_da_unidade_organizacional LIKE ?) AND (ano = ?) AND (entidade_id = ?)', '9%', self.ano, self.unidade.entidade_id] || (raise 'Não existe uma Unidade Organizacional Empresa válido')

		lancamento_debito = [{:tipo => 'D', :unidade_organizacional => unidade_organizacional,
				:plano_de_conta => self.unidade.parametro_conta_valor_cliente(self.ano_contabil_atual).conta_contabil,
				:centro => centro, :valor => self.valor_do_documento}]
		lancamento_credito = [{:tipo => 'C', :unidade_organizacional => unidade_organizacional,
				:plano_de_conta => self.unidade.parametro_conta_valor_faturamento(self.ano_contabil_atual).conta_contabil,
				:centro => centro, :valor => self.valor_do_documento}]

		#"Contrato #{self.numero_de_controle} gerado."
		Movimento.lanca_contabilidade(self.ano, [
				{:conta => self, :historico => self.historico, :numero_de_controle => self.numero_de_controle,
					:data_lancamento => data, :tipo_lancamento => 'S', :tipo_documento => self.tipo_de_documento,
					:provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id, :lancamento_inicial => true},
				lancamento_debito, lancamento_credito], self.unidade_id)
	end

  def calcula_porcentagens_dos_rateios(opcao)
    if opcao == 'normal'
      hash_rateio ||= {}
      self.parcelas.each do |parcela|
        unless [Parcela::CANCELADA, Parcela::RENEGOCIADA].include?(parcela.situacao)
          parcela.rateios.each do |rateio|
            hash_rateio[rateio.unidade_organizacional_id] ||= {}
            hash_rateio[rateio.unidade_organizacional_id][rateio.centro_id] ||= {}
            hash_rateio[rateio.unidade_organizacional_id][rateio.centro_id][rateio.conta_contabil_id] ||= 0
            hash_rateio[rateio.unidade_organizacional_id][rateio.centro_id][rateio.conta_contabil_id] += rateio.valor
          end
        end
      end
      hash_rateio
    elsif opcao == 'reajuste'
      hash_rateio_reajuste ||= {}
      self.parcelas.each do |parcela|
        if ![Parcela::CANCELADA, Parcela::RENEGOCIADA].include?(parcela.situacao) && parcela.data_vencimento.to_date >= self.reajustes.first.data_reajuste.to_date
          parcela.rateios.each do |rateio|
            hash_rateio_reajuste[rateio.unidade_organizacional_id] ||= {}
            hash_rateio_reajuste[rateio.unidade_organizacional_id][rateio.centro_id] ||= {}
            hash_rateio_reajuste[rateio.unidade_organizacional_id][rateio.centro_id][rateio.conta_contabil_id] ||= 0
            hash_rateio_reajuste[rateio.unidade_organizacional_id][rateio.centro_id][rateio.conta_contabil_id] += rateio.valor
          end
        end
      end
      hash_rateio_reajuste
    end
  end

  def self.calcular_proporcao(recebimentos_de_conta, historico, params)
  	ano_do_params = params["ano"].to_i
    mes_do_params = params["mes"].to_i
    hash_ax = {}
    lancamento_credito = []
    lancamento_debito = []
    begin
      n = 0
      c = 0
      RecebimentoDeConta.transaction do        
        if recebimentos_de_conta.respond_to?(:each)
          recebimentos_de_conta.each do |recebimento_de_conta|
            if [Normal, Juridico, Renegociado, Permuta, Baixa_do_conselho, Desconto_em_folha, Devedores_Duvidosos_Ativos, Enviado_ao_DR].include?(recebimento_de_conta.situacao_fiemt)
              intervalo = recebimento_de_conta.data_inicio_servico.to_date..recebimento_de_conta.data_final_servico.to_date
              total_dias = (intervalo.last - intervalo.first).to_i + 1
              
              result_hash = {}
              ultimo_mes = {:ano => 0, :mes => 0}
              (intervalo).collect do |date|
                result_hash[date.year] ||= {}
                result_hash[date.year][date.month] ||= 0
                result_hash[date.year][date.month] += 1
                if ultimo_mes[:ano] < date.year
                  ultimo_mes[:ano] = date.year
                  ultimo_mes[:mes] = date.month
                else
                  ultimo_mes[:mes] = date.month if ultimo_mes[:mes] < date.month
                end
              end
              total = 0
              result_hash.each do |year, months|
                months.sort.each do |month, days|
                  if recebimento_de_conta.rateio == NAO
                    result_hash[year][month] = ((((recebimento_de_conta.valor_original/100).to_f / total_dias) * days) * 100).to_i
                    total += result_hash[year][month]
                  else
                    if recebimento_de_conta.calcula_porcentagens_dos_rateios('normal').blank?
                      porcentagem_rateio = 1.0
                      hash_ax[year] ||= {}
                      hash_ax[year][month] ||= 0
                      hash_ax[year][month] += (((((recebimento_de_conta.valor_original/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                      if ano_do_params == year.to_i && mes_do_params == month.to_i
                        valor_item_rateio = (((((recebimento_de_conta.valor_original/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                        lancamento_credito << {:tipo => 'C', :unidade_organizacional => recebimento_de_conta.unidade_organizacional,
                          :centro => recebimento_de_conta.centro, :plano_de_conta =>  recebimento_de_conta.conta_contabil_receita,
                          :valor => valor_item_rateio}
                        total = hash_ax[year][month]
                      end
                    else
                      recebimento_de_conta.calcula_porcentagens_dos_rateios('normal').each do |unid_org_id, centros|
                        unidade_organizacional_rateio = UnidadeOrganizacional.find_by_id(unid_org_id)
                        centros.each do |centro_id, contas|
                          centro_rateio = Centro.find_by_id(centro_id)
                          if contas.respond_to?(:each)
                            contas.each do |conta_id, valor_rateio|
                              plano_de_conta_rateio = PlanoDeConta.find_by_id(conta_id)
                              
                              porcentagem_rateio = ((valor_rateio / (recebimento_de_conta.valor_original.real.to_f / 100)).round(2) / 100.0)



                              hash_ax[year] ||= {}
                              hash_ax[year][month] ||= 0
                              hash_ax[year][month] += (((((recebimento_de_conta.valor_original/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                              if ano_do_params == year.to_i && mes_do_params == month.to_i
                                valor_item_rateio = (((((recebimento_de_conta.valor_original/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                                lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_rateio,
                                  :plano_de_conta =>  plano_de_conta_rateio, :centro => centro_rateio,
                                  :valor => valor_item_rateio}
                                total = hash_ax[year][month]
                              end
                            end
                          end
                        end
                      end
                    end
                    result_hash = hash_ax
                  end
                end
              end
              
              if recebimento_de_conta.rateio == NAO
                if total < recebimento_de_conta.valor_original
                  diferenca = recebimento_de_conta.valor_original - total
                  result_hash[ultimo_mes[:ano]][ultimo_mes[:mes]] += diferenca
                end
              else
                soma_itens_rateio = []
                result_hash.collect{|chave_ano, val| val.collect{|chave_mes, chave_valor| soma_itens_rateio << chave_valor}}
                if soma_itens_rateio.sum < recebimento_de_conta.valor_original
                  diferenca = recebimento_de_conta.valor_original - soma_itens_rateio.sum
                  result_hash[ultimo_mes[:ano]][ultimo_mes[:mes]] += diferenca
                  lancamento_credito.last[:valor] += diferenca
                end
              end

              result_hash.each do |ano, parcelas|
                parcelas.each do |mes, valor|
                  if ano_do_params == ano.to_i && mes_do_params == mes.to_i
                    dia = Date.new(ano, mes, -1).day
                    data = "#{dia.to_s.rjust(2, '0')}/#{mes.to_s.rjust(2, '0')}/#{ano}"
                    nome_mes = Date::MONTHNAMES.compact[data.to_date.month - 1]

                    centro = Centro.first(:conditions => ["(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999999999', ano, recebimento_de_conta.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
                    unidade_organizacional = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999', ano, recebimento_de_conta.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional,
                      :plano_de_conta => recebimento_de_conta.unidade.parametro_conta_valor_faturamento(ano_do_params).conta_contabil,
                      :centro => centro, :valor => valor}

                    if recebimento_de_conta.rateio == SIM
                      val_aux = lancamento_credito.collect{|lanc| lanc[:valor]}.sum
                      diferenca = val_aux - valor
                      if val_aux > valor
                        lancamento_credito.last[:valor] -= diferenca
                      elsif val_aux < valor
                        lancamento_credito.last[:valor] += diferenca
                      end
                    else
                      lancamento_credito = [{:tipo => 'C',
                          :unidade_organizacional => recebimento_de_conta.unidade_organizacional,
                          :plano_de_conta => recebimento_de_conta.conta_contabil_receita,
                          :centro => recebimento_de_conta.centro, :valor => valor}]
                    end

                    movimentos = recebimento_de_conta.movimentos.select{|obj|
                      obj.tipo_lancamento == 'C' && !obj.lancamento_inicial && obj.provisao == Movimento::PROVISAO &&
                        !obj.parcela_id &&	recebimento_de_conta.id == obj.conta_id && obj.data_lancamento.to_date.month == mes}
                    if !movimentos.blank?
                      movimentos.each do |mov|
                        mov.destroy || raise("Não foi possível recontabilizar o contrato!\n\n#{mov.errors.full_messages.join("\n")}")
                      end
                    end

                    historico_ajustado = "#{historico} - #{nome_mes}/#{ano} (#{recebimento_de_conta.numero_de_controle} - #{recebimento_de_conta.pessoa.fisica? ? recebimento_de_conta.pessoa.nome : recebimento_de_conta.pessoa.razao_social})"
                    if historico_ajustado.length > 253
                      historico_ajustado = "#{historico} - #{nome_mes}/#{ano} (#{recebimento_de_conta.numero_de_controle})"
                    end
                    Movimento.lanca_contabilidade(ano, [{
                          :conta => recebimento_de_conta,
                          :historico => historico_ajustado,
                          :numero_de_controle => recebimento_de_conta.numero_de_controle,
                          :data_lancamento => data,
                          :tipo_lancamento => 'C',
                          :tipo_documento => recebimento_de_conta.tipo_de_documento,
                          :provisao => Movimento::PROVISAO,
                          :pessoa_id => recebimento_de_conta.pessoa_id},
                        lancamento_debito, lancamento_credito], recebimento_de_conta.unidade_id)
                    n += 1
                    hash_ax = {}
                    result_hash = {}
                    lancamento_debito = []
                    lancamento_credito = []
                  end
                end
              end
              lancamento_debito = []
              lancamento_credito = []
              #recebimento_de_conta.contabilizacao_da_receita = true
              recebimento_de_conta.save false if recebimento_de_conta.changed?
              c += 1
            end
          end
        end
      end
      [true, n, c]
    rescue Exception => e
      #LANCAMENTOS_LOGGER.erro e.backtrace.join("\n")
      [false, e.message]
    end
  end

  def self.contabilizacao_reajuste(recebimentos_de_conta, historico, params)
  	ano_do_params = params['ano'].to_i
    mes_do_params = params['mes'].to_i
    hash_ax = {}
    lancamento_credito = []
    lancamento_debito = []
    begin
      RecebimentoDeConta.transaction do
        recebimentos_de_conta.each do |recebimento_de_conta|
          reajuste = recebimento_de_conta.reajustes.first
          if !recebimento_de_conta.reajustes.blank? && [Normal, Juridico, Renegociado, Permuta, Baixa_do_conselho, Desconto_em_folha, Devedores_Duvidosos_Ativos, Enviado_ao_DR].include?(recebimento_de_conta.situacao_fiemt)
            intervalo = recebimento_de_conta.reajustes.first.data_reajuste.to_date..recebimento_de_conta.data_final_servico.to_date
            total_dias = (intervalo.last - intervalo.first).to_i + 1
            result_hash = {}
            ultimo_mes = {:ano => 0, :mes => 0}
            (intervalo).collect do |date|
              result_hash[date.year] ||= {}
              result_hash[date.year][date.month] ||= 0
              result_hash[date.year][date.month] += 1
              if ultimo_mes[:ano] < date.year
                ultimo_mes[:ano] = date.year
                ultimo_mes[:mes] = date.month
              else
                ultimo_mes[:mes] = date.month if ultimo_mes[:mes] < date.month
              end
            end
            total = 0
            unless result_hash[ano_do_params][mes_do_params].blank?
              result_hash.each do |year, months|
                months.sort.each do |month, days|
                  if recebimento_de_conta.rateio == NAO
                    result_hash[year][month] = ((((reajuste.valor_reajuste/100).to_f / total_dias) * days) * 100).to_i
                    total += result_hash[year][month]
                  else
                    if recebimento_de_conta.calcula_porcentagens_dos_rateios('reajuste').blank?
                      porcentagem_rateio = 1.0
                      hash_ax[year] ||= {}
                      hash_ax[year][month] ||= 0
                      hash_ax[year][month] += (((((reajuste.valor_reajuste/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                      if ano_do_params == year.to_i && mes_do_params == month.to_i
                        valor_item_rateio = (((((reajuste.valor_reajuste/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                        lancamento_credito << {:tipo => 'C', :unidade_organizacional => recebimento_de_conta.unidade_organizacional,
                          :centro => recebimento_de_conta.centro, :plano_de_conta =>  recebimento_de_conta.conta_contabil_receita,
                          :valor => valor_item_rateio}
                        total += hash_ax[year][month]
                      end
                    else
                      parcelas_reajustadas = recebimento_de_conta.parcelas.collect{|parcela| parcela.valor if ![Parcela::CANCELADA, Parcela::RENEGOCIADA].include?(parcela.situacao) && parcela.data_vencimento.to_date >= reajuste.data_reajuste.to_date}.compact
                      recebimento_de_conta.calcula_porcentagens_dos_rateios('reajuste').each do |unid_org_id, centros|
                        unidade_organizacional_rateio = UnidadeOrganizacional.find_by_id(unid_org_id)
                        centros.each do |centro_id, contas|
                          centro_rateio = Centro.find_by_id(centro_id)
                          contas.each do |conta_id, valor_rateio|
                            plano_de_conta_rateio = PlanoDeConta.find_by_id(conta_id)
                            porcentagem_rateio = ((valor_rateio / (parcelas_reajustadas.sum.real.to_f / 100)).round(1) / 100).round(2)
                            hash_ax[year] ||= {}
                            hash_ax[year][month] ||= 0
                            hash_ax[year][month] += (((((reajuste.valor_reajuste/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                            if ano_do_params == year.to_i && mes_do_params == month.to_i
                              valor_item_rateio = (((((reajuste.valor_reajuste/100).to_f / total_dias) * days) * porcentagem_rateio) * 100).to_i
                              lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_rateio,
                                :plano_de_conta =>  plano_de_conta_rateio, :centro => centro_rateio,
                                :valor => valor_item_rateio}
                              total = hash_ax[year][month]
                            end
                          end
                        end
                      end
                    end
                    result_hash = hash_ax
                  end
                end
              end
            end
            unless result_hash[ano_do_params][mes_do_params].blank?
              if recebimento_de_conta.rateio == NAO
                if total < reajuste.valor_reajuste
                  diferenca = reajuste.valor_reajuste - total
                  result_hash[ultimo_mes[:ano]][ultimo_mes[:mes]] += diferenca
                end
              else
                soma_itens_rateio = []
                result_hash.collect{|chave_ano, val| val.collect{|chave_mes, chave_valor| soma_itens_rateio << chave_valor}}
                if soma_itens_rateio.sum != reajuste.valor_reajuste
                  diferenca = reajuste.valor_reajuste - soma_itens_rateio.sum
                  result_hash[ultimo_mes[:ano]][ultimo_mes[:mes]] += diferenca
                  lancamento_credito.last[:valor] += diferenca
                end
              end
              result_hash.each do |ano, parcelas|
                parcelas.each do |mes, valor|
                  if ano_do_params == ano.to_i && mes_do_params == mes.to_i
                    dia = Date.new(ano, mes, -1).day
                    data = "#{dia.to_s.rjust(2, '0')}/#{mes.to_s.rjust(2, '0')}/#{ano}"
                    nome_mes = Date::MONTHNAMES.compact[data.to_date.month - 1]
                    centro = Centro.first(:conditions => ["(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999999999', ano, recebimento_de_conta.unidade.entidade_id]) || raise('Não existe um Centro de Responsabilidade Empresa válido.')
                    unidade_organizacional = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999', ano, recebimento_de_conta.unidade.entidade_id] || (raise 'Não existe uma Unidade Organizacional Empresa válido.')
                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional,
                      :plano_de_conta => recebimento_de_conta.unidade.parametro_conta_valor_faturamento(ano_do_params).conta_contabil,
                      :centro => centro, :valor => valor}
                    if recebimento_de_conta.rateio == SIM
                      val_aux = lancamento_credito.collect{|lanc| lanc[:valor]}.sum
                      diferenca = val_aux - valor
                      if val_aux > valor
                        lancamento_credito.last[:valor] -= diferenca
                      elsif val_aux < valor
                        lancamento_credito.last[:valor] += diferenca
                      end
                    else
                      lancamento_credito = [{:tipo => 'C',
                          :unidade_organizacional => recebimento_de_conta.unidade_organizacional,
                          :plano_de_conta => recebimento_de_conta.conta_contabil_receita,
                          :centro => recebimento_de_conta.centro, :valor => valor}]
                    end
                    movimentos = recebimento_de_conta.movimentos.select{|obj|
                      obj.tipo_lancamento == 'Z' && !obj.lancamento_inicial && obj.provisao == Movimento::PROVISAO &&
                        !obj.parcela_id &&	recebimento_de_conta.id == obj.conta_id && obj.data_lancamento.to_date.month == mes}
                    if !movimentos.blank?
                      movimentos.each do |mov|
                        mov.destroy || raise("Não foi possível recontabilizar o contrato!\n\n#{mov.errors.full_messages.join("\n")}")
                      end
                    end
                    Movimento.lanca_contabilidade(ano, [{
                          :conta => recebimento_de_conta,
                          :historico => "#{historico} - #{nome_mes}/#{ano} (Reajuste)",
                          :numero_de_controle => recebimento_de_conta.numero_de_controle,
                          :data_lancamento => data,
                          :tipo_lancamento => 'Z',
                          :tipo_documento => recebimento_de_conta.tipo_de_documento,
                          :provisao => Movimento::PROVISAO,
                          :pessoa_id => recebimento_de_conta.pessoa_id},
                        lancamento_debito, lancamento_credito], recebimento_de_conta.unidade_id)
                    hash_ax = {}
                    result_hash = {}
                    lancamento_debito = []
                    lancamento_credito = []
                  end
                end
              end
              lancamento_debito = []
              lancamento_credito = []
              #recebimento_de_conta.contabilizacao_da_receita = true
              recebimento_de_conta.save false
            end
          end
        end
      end
      [true, 'Reajustes OK']
    rescue Exception => e
      #LANCAMENTOS_LOGGER.erro e.backtrace.join("------------> REAJUSTE\n\n***********")
      [false, e.message]
    end
  end

  def after_validation
    if travado_pela_situacao?
      self.situacao = Inativo
      self.parcelas.each do |parcela|
        parcela.cancelar(self.usuario_corrente, "Contrato foi declarado como #{situacao_fiemt_verbose}", false, true)
      end
    end

    if self.liberacao_dr_faixa_de_dias_permitido == true
      self.liberacao_dr_faixa_de_dias_permitido = false
    end
  end

  def travado_pela_situacao?
    self.situacao_fiemt == Enviado_ao_DR || self.situacao_fiemt == Devedores_Duvidosos_Ativos
  end

  def validar_data_inicio
    return true if data_inicio.blank? || unidade.blank?
    if (data_inicio.to_date) >= (Date.today - unidade.lancamentoscontasreceber)
      true
    else
      false
    end
  end

  def validar_data_inicio_entre_limites
    return true if self.data_inicio.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if self.data_inicio.to_date.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def validar_datas(data)
    return true if data.blank? || unidade.blank?
    if (data.to_date) >= (Date.today - unidade.lancamentoscontasreceber)
      true
    else
      false
    end
  end

  def validar_datas_entre_limites(data)
    return true if data.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if data.to_date.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end


  def cancelamento_especial_1?
    parc = self.parcelas
    num_parc = 0 

    self.parcelas.each do |p|
     if !p.cartoes.blank? && p.situacao == Parcela::QUITADA
       num_parc += 1
     end
    end    


    i = 0
    j =0
    parc.each do |p|
    unless p.cartoes.blank?
      if p.situacao == Parcela::QUITADA
        i+=1
      end
     
        j+=1
      end
    end
    if i == num_parc && j > 0
      return true
    else
      return false
    end
  end

  def cancelamento_especial_2?(data_abdicacao = Date.today)
    parc = self.parcelas
    num_parc = self.parcelas.length
    i = 0
    j =0
    parc.each do |p|
      unless p.cartoes.blank?
      if p.situacao == Parcela::QUITADA && data_abdicacao.to_date >= p.data_vencimento.to_date
        i+=1
      end
     
        j+=1
      end
    end
    if i == num_parc && j > 0
      return true
    else
      return false
    end



  end


  def abdicar_contrato(data_abdicacao, usuario_corrente, justificativa)
    begin
      RecebimentoDeConta.transaction do
        if ![Evadido, Cancelado].include?(self.situacao_fiemt)
          if data_abdicacao.blank?
            return 'O campo data de cancelamento deve ser preenchido.'
          else
            if justificativa.blank?
              return 'O campo justificativa deve ser preenchido.'
            else
              if self.validar_datas(data_abdicacao.to_date) || self.validar_datas_entre_limites(data_abdicacao.to_date)                
              

              if self.cancelamento_especial_1?
                p "Entrei no cancelamento 1"
                  parcelas_para_estorno = []
                  self.parcelas.each do |p|
                    p  p.data_vencimento.to_date
                    p data_abdicacao.to_date
                    #p self.data_cancelamento.to_date
                    parcelas_para_estorno << p  if !p.cartoes.blank? && p.cartoes.first.situacao == 1
                  end

                
                  parcelas_para_estorno.each do |p1|
                   retorno =   p1.estorna_parcela(@usuario_corrente,"Estorno Cartão Pendente",data_abdicacao,false,true)
                  end




             #       lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
              #        :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => soma_parcelas_em_aberto}
              #      lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
              #        :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => soma_parcelas_em_aberto}

               #     Movimento.lanca_contabilidade(self.ano_contabil_atual, [
                #        {:conta => self, :historico => "#{self.historico} (Cancelamento de Contrato)", :numero_de_controle => self.numero_de_controle,
                 #         :data_lancamento => data_abdicacao.to_date, :tipo_lancamento => 'D',
                  #        :tipo_documento => self.tipo_de_documento,
                   #       :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
                   #     lancamento_debito, lancamento_credito], self.unidade_id)







               end


               if self.cancelamento_especial_2?
p "ENtrei no cancelamento 2"
                  parcelas_para_estorno = []
                  self.parcelas.each do |p|
                    p  p.data_vencimento.to_date
                    p data_abdicacao.to_date
                    #p self.data_cancelamento.to_date
                    parcelas_para_estorno << p if !p.cartoes.blank? && p.cartoes.first.situacao == 1
                  end

                 
                  parcelas_para_estorno.each do |p1|
                   retorno =   p1.estorna_parcela(@usuario_corrente,"Estorno Cartão Pendente",data_abdicacao,false,true)
                  end
                   data_da_abdicacao = data_abdicacao.to_date
                self.data_cancelamento = data_da_abdicacao
                self.situacao_fiemt = Cancelado
                self.abdicando = true
                self.save!
                return true

               end




                lancamento_credito = []
                lancamento_debito = []
                usuario_corrente = @usuario_corrente
                data_da_abdicacao = data_abdicacao.to_date
                self.data_cancelamento = data_da_abdicacao
                self.situacao_fiemt = Cancelado
                self.abdicando = true
                self.save!
                HistoricoOperacao.cria_follow_up("Contrato cancelado em #{data_abdicacao}", usuario_corrente, self, justificativa)
               












              
                soma_parcelas_em_aberto = 0
                soma_parcelas_pendentes = 0
                self.parcelas.each do |parcela|








                  if parcela.verifica_situacoes && parcela.data_vencimento.to_date >= data_abdicacao.to_date
                    parcela.situacao_antiga = parcela.situacao
                    parcela.situacao = Parcela::CANCELADA
                    parcela.save!
                    
                    if parcela.parcela_original
                      parcela.parcela_original.situacao = Parcela::CANCELADA
                      parcela.parcela_original.save false
                      parcela.parcela_original.conta.situacao_fiemt = Cancelado
                      parcela.parcela_original.conta.save false
                    elsif parcela.parcela_filha
                      parcela.parcela_filha.situacao = Parcela::CANCELADA
                      parcela.parcela_filha.save false
                      parcela.parcela_filha.conta.situacao_fiemt = Cancelado
                      parcela.parcela_filha.conta.save false
                    end

                    soma_parcelas_em_aberto += parcela.valor
                  elsif parcela.verifica_situacoes && parcela.data_vencimento.to_date < data_abdicacao.to_date
                    soma_parcelas_pendentes += parcela.valor
                  end
                end
                if self.provisao == SIM
                  unless self.unidade.blank?
                    raise 'Deve ser parametrizada uma conta contábil do tipo Cliente.' if self.unidade.parametro_conta_valor_cliente(self.ano_contabil_atual).blank?
                    raise 'Deve ser parametrizada uma conta contábil do tipo Faturamento.' if self.unidade.parametro_conta_valor_faturamento(self.ano_contabil_atual).blank?
                  end
                  conta_contabil_cliente = self.unidade.parametro_conta_valor_cliente(self.ano_contabil_atual).conta_contabil
                  conta_contabil_futuro = self.unidade.parametro_conta_valor_faturamento(self.ano_contabil_atual).conta_contabil
                  centro_empresa = Centro.first(:conditions => ["(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999999999', self.ano_contabil_atual, self.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
                  unidade_organizacional_empresa = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999', self.ano_contabil_atual, self.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

                  if soma_parcelas_em_aberto > 0
                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => soma_parcelas_em_aberto}
                    lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => soma_parcelas_em_aberto}

                    Movimento.lanca_contabilidade(self.ano_contabil_atual, [
                        {:conta => self, :historico => "#{self.historico} (Cancelamento de Contrato)", :numero_de_controle => self.numero_de_controle,
                          :data_lancamento => data_abdicacao.to_date, :tipo_lancamento => 'D',
                          :tipo_documento => self.tipo_de_documento,
                          :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
                        lancamento_debito, lancamento_credito], self.unidade_id)
                  end
                  lancamento_credito = []
                  lancamento_debito = []

                  parcs = self.parcelas.collect{|par| par.valor if par.data_da_baixa}.compact
                  movimentos_contabilizacao = self.movimentos.collect{|mov| mov.valor_total if mov.tipo_lancamento == 'C'}.compact
                  diferenca = parcs.sum - (movimentos_contabilizacao.sum - soma_parcelas_pendentes)
                  if diferenca > 0
                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => diferenca}
                    lancamento_credito << {:tipo => 'C', :unidade_organizacional => self.unidade_organizacional,
                      :plano_de_conta => self.conta_contabil_receita, :centro => self.centro, :valor => diferenca}
                  elsif diferenca < 0
                    diferenca = (-1) * diferenca
                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => self.unidade_organizacional,
                      :plano_de_conta => self.conta_contabil_receita, :centro => self.centro, :valor => diferenca}
                    lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => diferenca}
                  end
                  if diferenca > 0
                    Movimento.lanca_contabilidade(self.ano_contabil_atual, [
                        {:conta => self, :historico => "#{self.historico} (Cancelamento de Contrato)", :numero_de_controle => self.numero_de_controle,
                          :data_lancamento => data_abdicacao.to_date, :tipo_lancamento => 'D',
                          :tipo_documento => self.tipo_de_documento,
                          :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
                        lancamento_debito, lancamento_credito], self.unidade_id)
                  end
                  lancamento_debito = []
                  lancamento_credito = []

                  #RENEGOCIACAO
                  #                  movimentos_renegociacao = self.movimentos.collect{|mov| mov if mov.historico.include?('Renegociação')}.compact
                  #                  movimentos_renegociacao.each do |mov_ren|
                  #                    mov_estorno_reneg = mov_ren.clone
                  #                    mov_estorno_reneg.historico = self.historico + ' (Estorno de Renegociação)'
                  #                    mov_estorno_reneg.tipo_lancamento = 'H'
                  #                    mov_estorno_reneg.data_lancamento = Date.today
                  #                    mov_ren.itens_movimentos.each do |item|
                  #                      mov_estorno_reneg.itens_movimentos << item.clone
                  #                    end
                  #                    mov_estorno_reneg.itens_movimentos.each do |it|
                  #                      it.tipo = (it.tipo == 'C') ? 'D' : 'C'
                  #                      it.save!
                  #                    end
                  #                    mov_estorno_reneg.save!
                  #                  end

                  if self.parcelas.all?{|parc| parc.situacao == Parcela::QUITADA}
                    valor_todas_parcela_quitadas = self.parcelas.inject(0){|sum, parc| sum + parc.valor}
                    if valor_todas_parcela_quitadas > 0
                      lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
                        :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => valor_todas_parcela_quitadas}
                      lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
                        :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => valor_todas_parcela_quitadas}
                      Movimento.lanca_contabilidade(self.ano_contabil_atual, [
                          {:conta => self, :historico => "#{self.historico} (Cancelamento de Contrato)", :numero_de_controle => self.numero_de_controle,
                            :data_lancamento => data_abdicacao.to_date, :tipo_lancamento => 'D',
                            :tipo_documento => self.tipo_de_documento,
                            :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
                          lancamento_debito, lancamento_credito], self.unidade_id)
                    end
                  end
                end
                self.abdicando = false
                return true
              else
                raise('A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.')
              end
            end
          end
        else
          return 'Este contrato encontra-se cancelado!'
        end
      end
    rescue Exception => e
      e.message
    end
  end




















  def evadir_contrato(data_evasao, usuario_corrente, justificativa)
    begin
      RecebimentoDeConta.transaction do
        if ![Evadido, Cancelado].include?(self.situacao_fiemt)
          if data_evasao.blank?
            return 'O campo data de evasão deve ser preenchido.'
          else
            if justificativa.blank?
              return 'O campo justificativa deve ser preenchido.'
            else
              if self.validar_datas(data_evasao.to_date) || self.validar_datas_entre_limites(data_evasao.to_date)
                lancamento_credito = []
                lancamento_debito = []
                usuario_corrente = @usuario_corrente
                data_da_evasao = data_evasao.to_date
                self.data_evasao = data_da_evasao
                self.data_registro_evasao = Date.today
                self.situacao_fiemt = Evadido
                self.justificativa_evasao = justificativa
                self.evadindo = true
                self.save!
                HistoricoOperacao.cria_follow_up("Contrato evadido em #{data_evasao}", usuario_corrente, self, justificativa)
                valor_do_estorno = 0
                soma_parcelas_pendentes = 0
                self.parcelas.each do |parcela|
                  if parcela.verifica_situacoes && parcela.data_vencimento.to_date >= data_da_evasao
                    parcela.situacao_antiga = parcela.situacao
                    parcela.situacao = Parcela::EVADIDA
                    parcela.save!
                    valor_do_estorno += parcela.valor
                  elsif parcela.verifica_situacoes && parcela.data_vencimento.to_date < data_da_evasao
                    soma_parcelas_pendentes += parcela.valor
                  end
                end
                self.movimentos.each do |movimento|
                  if !movimento.lancamento_inicial && movimento.data_lancamento.to_date > data_da_evasao
                    movimento.destroy
                  end
                end
                if self.provisao == SIM
                  unless self.unidade.blank?
                    raise 'Deve ser parametrizada uma conta contábil do tipo Cliente.' if self.unidade.parametro_conta_valor_cliente(self.ano_contabil_atual).blank?
                    raise 'Deve ser parametrizada uma conta contábil do tipo Faturamento.' if self.unidade.parametro_conta_valor_faturamento(self.ano_contabil_atual).blank?
                  end
                  conta_contabil_cliente = self.unidade.parametro_conta_valor_cliente(self.ano_contabil_atual).conta_contabil
                  conta_contabil_futuro = self.unidade.parametro_conta_valor_faturamento(self.ano_contabil_atual).conta_contabil
                  centro_empresa = Centro.first(:conditions => ['(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)', '9999999999999999', self.ano_contabil_atual, self.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
                  unidade_organizacional_empresa = UnidadeOrganizacional.first :conditions => ['(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)', '9999999999', self.ano_contabil_atual, self.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

                  if valor_do_estorno > 0
                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => valor_do_estorno}
                    lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => valor_do_estorno}
                    Movimento.lanca_contabilidade(self.ano_contabil_atual, [
                        {:conta => self, :historico => "#{self.historico} (Evasão)", :numero_de_controle => self.numero_de_controle,
                          :data_lancamento => data_da_evasao, :tipo_lancamento => 'T', :tipo_documento => self.tipo_de_documento,
                          :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
                        lancamento_debito, lancamento_credito], self.unidade_id)
                  end
                  lancamento_credito = []
                  lancamento_debito = []

                  parcs = self.parcelas.collect{|par| par.valor if par.data_da_baixa}.compact
                  movimentos_contabilizacao = self.movimentos.collect{|mov| mov.valor_total if mov.tipo_lancamento == 'C'}.compact
                  diferenca = parcs.sum - (movimentos_contabilizacao.sum - soma_parcelas_pendentes)

                  if diferenca > 0
                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => diferenca}
                    lancamento_credito << {:tipo => 'C', :unidade_organizacional => self.unidade_organizacional,
                      :plano_de_conta => self.conta_contabil_receita, :centro => self.centro, :valor => diferenca}
                  elsif diferenca < 0
                    diferenca = (-1) * diferenca
                    lancamento_debito << {:tipo => 'D', :unidade_organizacional => self.unidade_organizacional,
                      :plano_de_conta => self.conta_contabil_receita, :centro => self.centro, :valor => diferenca}
                    lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
                      :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => diferenca}
                  end
                  if diferenca > 0
                    Movimento.lanca_contabilidade(self.ano_contabil_atual, [
                        {:conta => self, :historico => "#{self.historico} (Evasão)",
                          :numero_de_controle => self.numero_de_controle, :tipo_lancamento => 'T',
                          :data_lancamento => data_da_evasao, :tipo_documento => self.tipo_de_documento,
                          :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
                        lancamento_debito, lancamento_credito], self.unidade_id)
                  end
                  lancamento_debito = []
                  lancamento_credito = []

                  #RENEGOCIACAO
                  #                  movimentos_renegociacao = self.movimentos.collect{|mov| mov if mov.historico.include?('Renegociação')}.compact
                  #                  movimentos_renegociacao.each do |mov_ren|
                  #                    mov_estorno_reneg = mov_ren.clone
                  #                    mov_estorno_reneg.historico = self.historico + ' (Estorno de Renegociação)'
                  #                    mov_estorno_reneg.tipo_lancamento = 'G'
                  #                    mov_estorno_reneg.data_lancamento = Date.today
                  #                    mov_ren.itens_movimentos.each do |item|
                  #                      mov_estorno_reneg.itens_movimentos << item.clone
                  #                    end
                  #                    mov_estorno_reneg.itens_movimentos.each do |it|
                  #                      it.tipo = (it.tipo == 'C') ? 'D' : 'C'
                  #                      it.save!
                  #                    end
                  #                    mov_estorno_reneg.save!
                  #                  end
                  
                  if self.parcelas.all?{|parc| parc.situacao == Parcela::QUITADA}
                    valor_todas_parcela_quitadas = self.parcelas.inject(0){|sum, parc| sum + parc.valor}
                    if valor_todas_parcela_quitadas > 0
                      lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
                        :plano_de_conta => conta_contabil_futuro, :centro => centro_empresa, :valor => valor_todas_parcela_quitadas}
                      lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
                        :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => valor_todas_parcela_quitadas}
                      Movimento.lanca_contabilidade(self.ano_contabil_atual, [
                          {:conta => self, :historico => "#{self.historico} (Cancelamento de Contrato)", :numero_de_controle => self.numero_de_controle,
                            :data_lancamento => data_da_evasao, :tipo_lancamento => 'D',
                            :tipo_documento => self.tipo_de_documento,
                            :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
                          lancamento_debito, lancamento_credito], self.unidade_id)
                    end
                  end
                end
                self.evadindo = false
                return true
              else
                raise('A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.')
              end
            end
          end
        else
          return 'Este contrato encontra-se cancelado!'
        end
      end
    rescue Exception => e
      e.message
    end
  end

  def reverter_cancelamentos(usuario_corrente, justificativa, data_da_reversao)
    return [false, 'A Data da Reversão deve ser preenchida'] if data_da_reversao.blank?
    return [false, 'A Justificativa deve ser preenchida'] if justificativa.blank?
    data_reversao = data_da_reversao.to_date
    begin
      RecebimentoDeConta.transaction do
        if self.validar_datas(data_reversao) || self.validar_datas_entre_limites(data_reversao)
          self.situacao_fiemt = Normal
          self.revertendo = true
          self.data_reversao = data_reversao
          self.save!
          self.parcelas.each do |parcela|
            if parcela.situacao == Parcela::CANCELADA
              parcela.situacao = parcela.situacao_antiga.blank? ? Parcela::PENDENTE : parcela.situacao_antiga
              parcela.revertendo = true
              parcela.save!
              parcela.revertendo = false
            end
          end
          movimentos_cancelamento = self.movimentos.collect{|mov| mov if mov.tipo_lancamento == 'D'}.compact
          movimentos_cancelamento.each do |mov|
            if mov.data_lancamento.to_date == data_reversao
              mov.destroy
            elsif data_reversao > mov.data_lancamento.to_date
              movimento_estorno = mov.clone
              movimento_estorno.historico = self.historico + ' (Reversão de Cancelamento)'
              movimento_estorno.tipo_lancamento = 'V'
              movimento_estorno.data_lancamento = Date.today
              mov.itens_movimentos.each do |item|
                movimento_estorno.itens_movimentos << item.clone
              end
              movimento_estorno.itens_movimentos.each do |it|
                it.tipo = (it.tipo == 'C') ? 'D' : 'C'
                it.save!
              end
              movimento_estorno.save!
            end
          end
          HistoricoOperacao.cria_follow_up("Contrato revertido em #{data_reversao.to_s_br}", usuario_corrente, self, justificativa)
          self.revertendo = false
          return [true, 'Sucesso']
        else
          return [false, 'A data inserida excedeu os limites de dias retroativos permitidos']
        end
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def reverter_evasao(usuario_corrente, justificativa, data_da_reversao)
    return [false, 'A Data da Reversão deve ser preenchida'] if data_da_reversao.blank?
    return [false, 'A Justificativa deve ser preenchida'] if justificativa.blank?
    data_reversao_evasao = data_da_reversao.to_date
    begin
      RecebimentoDeConta.transaction do
        if self.validar_datas(data_reversao_evasao) || self.validar_datas_entre_limites(data_reversao_evasao)
          self.situacao_fiemt = Normal
          self.revertendo_evasao = true
          self.data_evasao = nil
          self.data_reversao_evasao = data_reversao_evasao
          self.save!
          self.parcelas.each do |parcela|
            if parcela.situacao == Parcela::EVADIDA
              parcela.situacao = parcela.situacao_antiga.blank? ? Parcela::PENDENTE : parcela.situacao_antiga
              parcela.revertendo_evasao = true
              parcela.save!
              parcela.revertendo_evasao = false
            end
          end
          movimentos_cancelamento = self.movimentos.collect{|mov| mov if mov.tipo_lancamento == 'T'}.compact
          movimentos_cancelamento.each do |mov|
            if mov.data_lancamento.to_date == data_reversao_evasao
              mov.destroy
            elsif data_reversao_evasao > mov.data_lancamento.to_date
              movimento_estorno = mov.clone
              movimento_estorno.historico = self.historico + ' (Reversão de Evasão)'
              movimento_estorno.tipo_lancamento = 'O'
              movimento_estorno.data_lancamento = Date.today
              mov.itens_movimentos.each do |item|
                movimento_estorno.itens_movimentos << item.clone
              end
              movimento_estorno.itens_movimentos.each do |it|
                it.tipo = (it.tipo == 'C') ? 'D' : 'C'
                it.save!
              end
              movimento_estorno.save!
            end
          end
          HistoricoOperacao.cria_follow_up("Evasão de contrato revertida em #{data_reversao_evasao.to_s_br}", usuario_corrente, self, justificativa)
          self.revertendo_evasao = false
          return [true, 'Sucesso']
        else
          return [false, 'A data inserida excedeu os limites de dias retroativos permitidos']
        end
      end
    rescue Exception => e
      [false, e.message]
    end
  end
  
  def contrato_evadido?
    !self.data_evasao.blank?
  end

  def calculo_total_desconto_percentual
    self.parcelas.find_all{|parcela| parcela.situacao == Parcela::PENDENTE}.collect{|parcela| parcela.percentual_de_desconto.to_f / 100.0}.sum
  end

  # RF6
  def numero_de_parcelas_atrasadas
    self.parcelas.collect do |parcela|
      if parcela.situacao == Parcela::PENDENTE && parcela.data_vencimento.to_date < Date.today
        parcela.id
      end
    end.compact.length
  end

  # RF6
  def calcula_valor_a_ser_pago(data_base = Date.today.to_s_br)
    array_com_informacoes_sobre_juros_multa_e_valor_corrigido = [0, 0]
    valor_corrigido = 0
    self.parcelas.each do |parcela|
      if parcela.situacao == Parcela::PENDENTE && parcela.data_vencimento.to_date < Date.today
        resultado_do_calculo = Gefin.calcular_juros_e_multas({:vencimento => parcela.data_vencimento, :valor => parcela.valor,
            :data_base => data_base, :juros => parcela.conta.juros_por_atraso, :multa => parcela.conta.multa_por_atraso})
        valor_corrigido += resultado_do_calculo[2]
        array_com_informacoes_sobre_juros_multa_e_valor_corrigido[0] += resultado_do_calculo[0]
        array_com_informacoes_sobre_juros_multa_e_valor_corrigido[1] += resultado_do_calculo[1]
      end
      if parcela.situacao == Parcela::PENDENTE && parcela.data_vencimento.to_date >= Date.today
        valor_corrigido += parcela.valor
      end
    end
    array_com_informacoes_sobre_juros_multa_e_valor_corrigido << valor_corrigido
    return array_com_informacoes_sobre_juros_multa_e_valor_corrigido
  end

  # RF6
  def calcula_valor_ja_pago
    valor_pago = 0
    self.parcelas.each do |parcela|
      if parcela.situacao == Parcela::QUITADA
        valor_pago += parcela.valor_liquido
      end
    end
    return valor_pago
  end

  # RF6
  def self.pesquisa_por_datas_e_parcelas_atrasadas(unidade_id, params = {})
    @sqls = ['recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.envio_para_dr IS NULL AND recebimento_de_contas.envio_para_terceirizada IS NULL AND parcelas.situacao = ? AND parcelas.data_vencimento < ?']; @variaveis = [unidade_id, Parcela::PENDENTE, Date.today]
    unless params[:data_inicial].blank?
      @sqls << "recebimento_de_contas.data_inicio >= ?"
      @variaveis << params[:data_inicial].to_date
    end
    unless params[:data_final].blank?
      @sqls << "recebimento_de_contas.data_inicio <= ?"
      @variaveis << params[:data_final].to_date
    end

    RecebimentoDeConta.all(:include => [:parcelas], :conditions => [@sqls.join(" AND ")] + @variaveis)
  end

  # RF6
  def self.carrega_recebimentos_para_envio(usuario_corrente, unidade_id, params)
    retorno = []
    if !params[:data_inicial].blank? || !params[:data_final].blank?
      @sqls = ['recebimento_de_contas.unidade_id = ?']; @variaveis = [unidade_id]
      @sqls << "recebimento_de_contas.envio_para_dr = ? AND recebimento_de_contas.envio_para_terceirizada = ?"
      if params[:dr_ou_terceirizada].to_i == DR
        @variaveis << 1; @variaveis << 0
      elsif params[:dr_ou_terceirizada].to_i == TERCEIRIZADA
        @variaveis << 0; @variaveis << 1
      end
      unless params[:data_inicial].blank?
        @sqls << "recebimento_de_contas.data_inicio >= ?"
        @variaveis << params[:data_inicial].to_date
      end
      unless params[:data_final].blank?
        @sqls << "recebimento_de_contas.data_inicio <= ?"
        @variaveis << params[:data_final].to_date
      end
      unless params[:ids].blank?
        @sqls << "id NOT IN (?)"
        @variaveis << params[:ids]
      end
      retorno = retorno + RecebimentoDeConta.all(:conditions => [@sqls.join(" AND ")] + @variaveis)
    end
    unless params[:ids].blank?
      params[:ids].each do |id|
        recebimento_de_conta = RecebimentoDeConta.find_by_id_and_unidade_id(id, unidade_id)
        if recebimento_de_conta.envio_para_dr == nil && recebimento_de_conta.envio_para_terceirizada == nil
          if params[:dr_ou_terceirizada].to_i == DR
            recebimento_de_conta.envio_para_dr, recebimento_de_conta.envio_para_terceirizada = [true, false]
          elsif params[:dr_ou_terceirizada].to_i == TERCEIRIZADA
            recebimento_de_conta.envio_para_dr, recebimento_de_conta.envio_para_terceirizada = [false, true]
          end
          if recebimento_de_conta.valid? && recebimento_de_conta.changed?
            recebimento_de_conta.save
            recebimento_de_conta.parcelas.each do |parcela|
              if parcela.situacao == Parcela::PENDENTE && parcela.data_vencimento.to_date < Date.today
                parcela.cancelar(usuario_corrente, 'Contrato enviado ao DR/Terceirizada', true, false)
              end
            end
            retorno << recebimento_de_conta
          end
        end
      end
    end
    retorno
  end

  def self.procurar_contratos_para_prorrogacao(params, unidade_id)
    servico_id = !params[:nome_servico].blank? ? params[:servico_id] : ''

    if(servico_id.blank?)
      return []
    end

    if params[:datas] == 'inicio_servico'
      if !params["data_min"].blank? && !params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_inicio_servico >= ?) AND (data_inicio_servico <= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_min"].to_date, params["data_max"].to_date, false, Cancelado, Evadido])
      elsif !params["data_min"].blank? && params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_inicio_servico >= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_min"].to_date, false, Cancelado, Evadido])
      elsif params["data_min"].blank? && !params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_inicio_servico <= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_max"].to_date, false, Cancelado, Evadido])
      elsif params["data_min"].blank? && params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, false, Cancelado, Evadido])
      end
    end

    if params[:datas] == 'final_servico'
      if !params["data_min"].blank? && !params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_final_servico >= ?) AND (data_final_servico <= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_min"].to_date, params["data_max"].to_date, false, Cancelado, Evadido])
      elsif !params["data_min"].blank? && params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_final_servico >= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_min"].to_date, false, Cancelado, Evadido])
      elsif params["data_min"].blank? && !params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_final_servico <= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_max"].to_date, false, Cancelado, Evadido])
      elsif params["data_min"].blank? && params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, false, Cancelado, Evadido])
      end
    end

    if params[:datas] == 'intervalo'
      if !params["data_min"].blank? && !params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_inicio_servico >= ?) AND (data_final_servico <= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_min"].to_date, params["data_max"].to_date, false, Cancelado, Evadido])
      elsif !params["data_min"].blank? && params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_inicio_servico >= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_min"].to_date, false, Cancelado, Evadido])
      elsif params["data_min"].blank? && !params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (data_inicio_servico <= ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, params["data_max"].to_date, false, Cancelado, Evadido])
      elsif params["data_min"].blank? && params["data_max"].blank?
        return RecebimentoDeConta.find(:all, :conditions => ['(unidade_id = ?) AND (servico_id = ?) AND (servico_iniciado = ?) AND (situacao_fiemt <> ? AND situacao_fiemt <> ?)', unidade_id, servico_id, false, Cancelado, Evadido])
      end
    end

  end

  def self.prorroga_todos_contratos(usuario, recebimentos, params, ano)
    recebimento_de_contas = []
    recebimentos.each do |id|
      recebimento_de_contas << RecebimentoDeConta.find(id)
    end
    begin
      RecebimentoDeConta.transaction do
        recebimento_de_contas.each do |conta|
          if conta.servico_nao_iniciado?
            conta.prorrogando = true
            conta.update_attributes!(:data_inicio_servico => params['nova_data_inicio'], :data_final_servico => params['nova_data_final'])
          else
            return [false, 'O serviço não pode ser prorrogado uma vez que já foi iniciado.']
          end
          HistoricoOperacao.cria_follow_up("Serviço prorrogado, nova data de início dos serviços em #{conta.data_inicio_servico} com vigência de #{conta.vigencia} meses, finalizando em #{conta.data_final_servico}.", usuario, conta, '')
          conta.prorrogando = false
        end
      end
      return [true, 'Contratos prorrogados com sucesso!']
    rescue Exception => e
      return [false, e.message]
    end
  end

  def pode_ser_modificado?
    self.situacao_was == Cancelado ? false : true
  end

  def renegociar(params, ano, senha = nil)
    begin
      RecebimentoDeConta.transaction do
        $novas_parcelas_da_renegociacao ||= {}
        $parcelas_sendo_renegociadas ||= {}
        $novas_parcelas_da_renegociacao[self.id] = {}
        $parcelas_sendo_renegociadas[self.id] = {}
        parcelas_selecionadas = []
        valor_atual_das_parcelas = []
        array_contador = []
        array_valores = []
        self.parcelas.collect{|pc| array_contador << pc.numero.to_i if pc.verifica_situacoes}
        contador = array_contador.max + 1
        params['parcelas_id'].each do |id_parc|
          parcelas_selecionadas << Parcela.find(id_parc)
        end

        parcelas_selecionadas.each{|parcela| valor_atual_das_parcelas << parcela.valor if parcela.verifica_situacoes}
        valor_das_parcelas_renegociadas = (params['valor_parcelas_selec'].real.to_f * 100).round
        valor_dos_juros = valor_das_parcelas_renegociadas - valor_atual_das_parcelas.sum
        valor_da_entrada = (params['valor_da_entrada'].real.to_f * 100).to_i
        valor_para_novas_parcelas = valor_das_parcelas_renegociadas - valor_da_entrada
        numero_novas_parcelas = params['numero_de_parcelas'].to_i

        #        #  p params


        #       parcela.desconto_em_porcentagem = params['desconto_em_porcentagem'] rescue 0
        #parcela.percentual_de_desconto = (params['desconto_em_porcentagem'].to_f * 100.0).to_i rescue 0

        if valor_dos_juros > 0
          parcelas_selecionadas.each do |parcela|
            if parcela.verifica_situacoes
              parcela.situacao = Parcela::RENEGOCIADA
              parcela.save!
              $parcelas_sendo_renegociadas[self.id][parcela.id] = parcela
            end
          end
          self.numero_de_renegociacoes += 1
          self.numero_de_parcelas = self.parcelas.length - parcelas_selecionadas.length + numero_novas_parcelas
          self.renegociando = true
          self.save false

          nova_parcela = Parcela.new
          nova_parcela.conta_id = self.id
          nova_parcela.conta_type = 'RecebimentoDeConta'
          nova_parcela.numero = contador.to_s
          nova_parcela.valor = valor_da_entrada
          
          if params['data_entrada'] == 'amanha'
            nova_parcela.data_vencimento = (Date.today + 1)
          else
            nova_parcela.data_vencimento = Date.today
          end
          nova_parcela.situacao = Parcela::PENDENTE
          nova_parcela.save false
          $novas_parcelas_da_renegociacao[self.id][nova_parcela.id] = nova_parcela
          contador += 1
          vencimento = self.gerar_nova_data_de_vencimento_renegociacao(nova_parcela.data_vencimento, params['recebimento_de_conta']['dia_do_vencimento'].to_i)
          1.upto(numero_novas_parcelas) do |numero|
            val_parcela =  valor_para_novas_parcelas / numero_novas_parcelas
            val_parcela = format('%.2f', val_parcela).to_f
            valor_para_novas_parcelas = valor_para_novas_parcelas - val_parcela.round
            numero_novas_parcelas = numero_novas_parcelas - 1
            parce = self.parcelas.create! :valor => val_parcela.round, :data_vencimento => vencimento,
              :numero => contador.to_s, :situacao => (self.atribui_situacao.blank? ? Parcela::PENDENTE : self.atribui_situacao)
            vencimento = vencimento.to_date + 1.month
            if self.rateio == 1
              Rateio.create! :parcela => parce, :unidade_organizacional => self.unidade_organizacional,
                :centro => self.centro, :conta_contabil => self.conta_contabil_receita, :valor => parce.valor
            end
            $novas_parcelas_da_renegociacao[self.id][parce.id] = parce
            contador += 1
          end

          if self.rateio == 1
            novo_rateio = Rateio.new(:unidade_organizacional_id => self.unidade_organizacional_id,
              :centro_id => self.centro_id,
              :conta_contabil_id => self.conta_contabil_receita_id,
              :valor => nova_parcela.valor,
              :parcela_id => nova_parcela.id)
            novo_rateio.save!
          end
          self.parcelas.reload
          self.parcelas.collect{|p| array_valores << p.valor if p.verifica_situacoes}
          self.valor_do_documento = array_valores.sum
          self.save false

          if self.provisao == SIM
            unless self.unidade.blank?
              raise 'Deve ser parametrizada uma conta contábil do tipo Cliente.' if self.unidade.parametro_conta_valor_cliente(ano).blank?
              raise 'Deve ser parametrizada uma conta contábil do tipo Juros e Multas de Contratos Renegociados.' if self.unidade.parametro_conta_valor_juros_multas_renegociados(ano).blank?
            end
            conta_contabil_cliente = self.unidade.parametro_conta_valor_cliente(ano).conta_contabil
            conta_contabil_juros_multa = self.unidade.parametro_conta_valor_juros_multas_renegociados(ano).conta_contabil
            centro_empresa = Centro.first(:conditions => ["(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999999999', ano, self.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
            unidade_organizacional_empresa = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999', ano, self.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")
            if valor_das_parcelas_renegociadas != valor_atual_das_parcelas.sum
              lancamento_debito = [{:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
                  :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => valor_dos_juros}]
              lancamento_credito = [{:tipo => 'C', :unidade_organizacional => self.unidade_organizacional,
                  :plano_de_conta => conta_contabil_juros_multa, :centro => self.centro, :valor => valor_dos_juros}]

              Movimento.lanca_contabilidade(ano, [
                  {:conta => self, :historico => "#{params['historico_renegociacao']} (Renegociação)",
                    :numero_de_controle => self.numero_de_controle, :provisao => Movimento::PROVISAO,
                    :data_lancamento => Date.today, :tipo_lancamento => 'S', :tipo_documento => self.tipo_de_documento,
                    :pessoa_id => self.pessoa_id},
                  lancamento_debito, lancamento_credito], self.unidade_id)
            end
          end
        elsif valor_dos_juros < 0


          unless valida_senha(self, senha)
            return [false, 1, 'O valor inserido apresenta um desconto. Insira a senha de liberação válida e confirme novamente a operação.']
          else
            parcelas_selecionadas.each do |parcela|
              if parcela.verifica_situacoes
                parcela.situacao = Parcela::RENEGOCIADA
                parcela.save!
                $parcelas_sendo_renegociadas[self.id][parcela.id] = parcela
              end
            end
            self.numero_de_renegociacoes += 1
            self.numero_de_parcelas = self.parcelas.length - parcelas_selecionadas.length + numero_novas_parcelas
            self.renegociando = true
            self.save false
            nova_parcela = Parcela.new
            nova_parcela.conta_id = self.id
            nova_parcela.conta_type = 'RecebimentoDeConta'
            nova_parcela.numero = contador.to_s
            nova_parcela.valor = valor_da_entrada
            if params['data_entrada'] == 'amanha'
              nova_parcela.data_vencimento = (Date.today + 1)
            else
              nova_parcela.data_vencimento = Date.today
            end
            nova_parcela.situacao = Parcela::PENDENTE
            nova_parcela.save false
            $novas_parcelas_da_renegociacao[self.id][nova_parcela.id] = nova_parcela
            contador += 1
            vencimento = self.gerar_nova_data_de_vencimento_renegociacao(nova_parcela.data_vencimento, params['recebimento_de_conta']['dia_do_vencimento'].to_i)
            1.upto(numero_novas_parcelas) do |numero|
              val_parcela =  valor_para_novas_parcelas / numero_novas_parcelas
              val_parcela = format("%.2f", val_parcela).to_f
              valor_para_novas_parcelas = valor_para_novas_parcelas - val_parcela.round
              numero_novas_parcelas = numero_novas_parcelas - 1
              parce = self.parcelas.create! :valor => val_parcela.round, :data_vencimento => vencimento, :numero => contador.to_s, :situacao => (self.atribui_situacao.blank? ? Parcela::PENDENTE : self.atribui_situacao)
              vencimento = vencimento.to_date + 1.month
              if self.rateio == 1
                Rateio.create! :parcela => parce, :unidade_organizacional => self.unidade_organizacional,
                  :centro => self.centro, :conta_contabil => self.conta_contabil_receita, :valor => parce.valor
              end
              $novas_parcelas_da_renegociacao[self.id][parce.id] = parce
              contador += 1
            end

            if self.rateio == 1
              novo_rateio = Rateio.new(:unidade_organizacional_id => self.unidade_organizacional_id,
                :centro_id => self.centro_id,
                :conta_contabil_id => self.conta_contabil_receita_id,
                :valor => nova_parcela.valor,
                :parcela_id => nova_parcela.id)
              novo_rateio.save!
            end
            self.parcelas.reload
            self.parcelas.collect{|p| array_valores << p.valor if p.verifica_situacoes}
            self.valor_do_documento = array_valores.sum
            self.save false

            if self.provisao == SIM
              unless self.unidade.blank?
                raise "Deve ser parametrizada uma conta contábil do tipo Cliente." if self.unidade.parametro_conta_valor_cliente(ano).blank?
                raise "Deve ser parametrizada uma conta contábil do tipo Desconto PF." if self.pessoa.tipo_pessoa == Pessoa::FISICA && self.unidade.parametro_conta_valor_pessoa_fisica(ano).blank?
                raise "Deve ser parametrizada uma conta contábil do tipo Desconto PJ." if self.pessoa.tipo_pessoa == Pessoa::JURIDICA && self.unidade.parametro_conta_valor_pessoa_juridica(ano).blank?
              end
              conta_contabil_cliente = self.unidade.parametro_conta_valor_cliente(ano).conta_contabil
              conta_contabil_pessoa = self.pessoa.fisica? ? self.unidade.parametro_conta_valor_pessoa_fisica(ano).conta_contabil : self.unidade.parametro_conta_valor_pessoa_juridica(ano).conta_contabil
              centro_empresa = Centro.first(:conditions => ["(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999999999', ano, self.unidade.entidade_id]) || (raise "Não existe um Centro de Responsabilidade Empresa válido.")
              unidade_organizacional_empresa = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999', ano, self.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

              valor_do_desconto = -(valor_dos_juros)
              lancamento_debito = [{:tipo => "D", :unidade_organizacional => self.unidade_organizacional,
                  :plano_de_conta => conta_contabil_pessoa, :centro => self.centro, :valor => valor_do_desconto}]
              lancamento_credito = [{:tipo => "C", :unidade_organizacional => unidade_organizacional_empresa,
                  :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => valor_do_desconto}]

              Movimento.lanca_contabilidade(ano, [
                  {:conta => self, :historico => "#{params['historico_renegociacao']} (Renegociação)",
                    :numero_de_controle => self.numero_de_controle, :provisao => Movimento::PROVISAO,
                    :data_lancamento => Date.today, :tipo_lancamento => "S", :tipo_documento => self.tipo_de_documento,
                    :pessoa_id => self.pessoa_id},
                  lancamento_debito, lancamento_credito], self.unidade_id)

            end
          end
        else


          parcelas_selecionadas.each do |parcela|
            if parcela.verifica_situacoes
              parcela.situacao = Parcela::RENEGOCIADA
              parcela.save!
              $parcelas_sendo_renegociadas[self.id][parcela.id] = parcela
            end
          end
          self.numero_de_renegociacoes += 1
          self.numero_de_parcelas = self.parcelas.length - parcelas_selecionadas.length + numero_novas_parcelas
          self.renegociando = true
          self.save false
          nova_parcela = Parcela.new
          nova_parcela.conta_id = self.id
          nova_parcela.conta_type = 'RecebimentoDeConta'
          nova_parcela.numero = contador.to_s
          nova_parcela.valor = valor_da_entrada
          if params['data_entrada'] == 'amanha'
            nova_parcela.data_vencimento = (Date.today + 1)
          else
            nova_parcela.data_vencimento = Date.today
          end
          nova_parcela.situacao = Parcela::PENDENTE
          nova_parcela.save false
          $novas_parcelas_da_renegociacao[self.id][nova_parcela.id] = nova_parcela
          contador += 1
          vencimento = self.gerar_nova_data_de_vencimento_renegociacao(nova_parcela.data_vencimento, params['recebimento_de_conta']['dia_do_vencimento'].to_i)
          1.upto(numero_novas_parcelas) do |numero|
            val_parcela =  valor_para_novas_parcelas / numero_novas_parcelas
            val_parcela = format("%.2f", val_parcela).to_f
            valor_para_novas_parcelas = valor_para_novas_parcelas - val_parcela.round
            numero_novas_parcelas = numero_novas_parcelas - 1
            parce = self.parcelas.create! :valor => val_parcela.round, :data_vencimento => vencimento, :numero => contador.to_s, :situacao => (self.atribui_situacao.blank? ? Parcela::PENDENTE : self.atribui_situacao)
            vencimento = vencimento.to_date + 1.month
            if self.rateio == 1
              Rateio.create! :parcela => parce, :unidade_organizacional => self.unidade_organizacional,
                :centro => self.centro, :conta_contabil => self.conta_contabil_receita, :valor => parce.valor
            end
            $novas_parcelas_da_renegociacao[self.id][parce.id] = parce
            contador += 1
          end

          if self.rateio == 1
            novo_rateio = Rateio.new(:unidade_organizacional_id => self.unidade_organizacional_id,
              :centro_id => self.centro_id,
              :conta_contabil_id => self.conta_contabil_receita_id,
              :valor => nova_parcela.valor,
              :parcela_id => nova_parcela.id)
            novo_rateio.save!
          end
          self.parcelas.reload
          self.parcelas.collect{|p| array_valores << p.valor if p.verifica_situacoes}
          self.valor_do_documento = array_valores.sum
          self.save false
        end

        self.renegociando = false
        HistoricoOperacao.cria_follow_up("Renegociação número #{self.numero_de_renegociacoes} do contrato efetuada", self.usuario_corrente, self)
        [true, 'Dados gravados com sucesso!']
      end
    rescue Exception => e
      # p e.message
      [false, e.message]
    end
  end

  def valida_senha(conta, senha)
    senha_unidade = conta.unidade.senha_baixa_dr
    retorno = senha_unidade == senha ? true : false
    return retorno
  end

  def inserir_nova_parcela(params)
    begin
      self.inserindo_nova_parcela = true
      #      valor_da_parcela = params["valor"].to_f * 100
      valor_da_parcela = params["valor"].real.to_f * 100
      valor_da_multa = params["valor_da_multa"].to_f * 100
      valor_dos_juros = params["valor_dos_juros"].to_f * 100
      array_parcelas = []
      self.parcelas.each{|parc| array_parcelas << parc.id if parc.situacao != Parcela::RENEGOCIADA && parc.numero_parcela_filha.blank?}
      self.parcelas.build :valor => valor_da_parcela.round, :data_vencimento => params["data_vencimento"],:porcentagem_multa => params["porcentagem_multa"],:porcentagem_juros => params["porcentagem_juros"], :situacao => self.atribui_situacao, :valor_da_multa => valor_da_multa, :valor_dos_juros => valor_dos_juros, :numero => array_parcelas.length + 1
      self.valor_do_documento += valor_da_parcela.round
      self.numero_de_parcelas = self.numero_de_parcelas + 1
      self.save!
      Rateio.create! :parcela => Parcela.last, :unidade_organizacional => self.unidade_organizacional, :centro => self.centro, :conta_contabil => self.conta_contabil_receita, :valor => Parcela.last.valor if self.rateio == 1
      HistoricoOperacao.cria_follow_up("Parcela de numero #{array_parcelas.length + 1} criada.", self.usuario_corrente, self, nil, nil, valor_da_parcela.round)
      return [true, "Parcela gerada com sucesso."]
    rescue Exception => e
      [false,e.message]
    end
  end

  def atualizar_valor_das_parcelas(ano, params, usuario)
    soma_parcelas = 0
    begin
      self.atualizando_parcelas = true
      RecebimentoDeConta.transaction do
        return 'A soma do valor das parcelas não é igual ao valor das parcelas pendentes' if valores_das_parcelas_sao_diferentes?(params)
        retorno_da_funcao = datas_estao_incorretas?(params)
        return retorno_da_funcao.last if retorno_da_funcao.first
        params.each do |id, conteudo|
          parcela = Parcela.find_by_id_and_conta_id id.to_i, self.id
          if parcela.situacao != Parcela::QUITADA
            unless [Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(parcela.situacao)
              atributos = {:valor => (conteudo["valor"].real.quantia), :data_vencimento => conteudo["data_vencimento"]}
              soma_parcelas += conteudo["valor"].real.to_f * 100
              if self.rateio == 1
                if(parcela.valor != atributos[:valor] || parcela.data_vencimento != atributos[:data_vencimento])
                  refaz_proporcionalmente_o_rateio(atributos, parcela)
                  resultado = parcela.grava_itens_do_rateio(ano, usuario, true)
                  if resultado.first != true
                    raise "#{resultado.last}"
                  end
                end
              else
                if(parcela.valor != atributos[:valor] || parcela.data_vencimento != atributos[:data_vencimento])
                  parcela.update_attributes!(atributos)
                  HistoricoOperacao.cria_follow_up("A parcela numero #{parcela.numero} foi alterada", usuario, parcela.conta)
                end
              end
            end
          end
        end
        #self.update_attribute(:valor_do_documento, soma_parcelas)
        return true
      end
    rescue Exception => e
      e.message
    end
  end

  def refaz_proporcionalmente_o_rateio(dados, parcela)
    valor_das_porcentagens = []
    soma = 0
    parcela.dados_do_rateio.each do |chave, conteudo|
      porcentagem = conteudo["porcentagem"].to_f / 100
      valor_das_porcentagens << porcentagem
    end
    parcela.valor = dados[:valor].round
    parcela.data_vencimento = dados[:data_vencimento]
    valor_das_porcentagens.each_with_index do |conteudo,indice|
      chave = indice + 1
      if chave != valor_das_porcentagens.length
        valor = ((dados[:valor] * conteudo) / 100.0).round
        parcela.dados_do_rateio[chave.to_s]["valor"] = valor.to_s
        soma += valor.to_f * 100
      else
        parcela.dados_do_rateio[chave.to_s]["valor"] = ((parcela.valor - soma) / 100.0).to_s
      end
    end
  end

  def datas_estao_incorretas?(params)
    params.each do |chave, conteudo|
      return [true, 'A data de vencimento deve ser preenchida'] if conteudo['data_vencimento'].blank?
      return [true, "A parcela com data de vencimento #{conteudo['data_vencimento']} é inválida, pois a data de início do contrato é #{self.data_inicio}"] if (![Parcela::QUITADA, Parcela::CANCELADA, Parcela::EVADIDA, Parcela::RENEGOCIADA].include?(conteudo['situacao'].to_i) && conteudo['data_vencimento'].to_date < self.data_inicio.to_date)
    end
    return [false, nil]
  end

  def valores_das_parcelas_sao_diferentes?(params)
    soma = 0
    params.each do |id, conteudo|
      parcela = Parcela.find_by_id_and_conta_id(id.to_i, self.id)
      if parcela.situacao != Parcela::QUITADA
        soma += (conteudo["valor"].gsub(".", "").gsub(",", ".")).to_f * 100
      end
    end
    #soma = params.sum { |_, conteudo| (conteudo["valor"].gsub(".", "").gsub(",", ".")).to_f * 100 }
    soma_das_parcelas_pendentes = parcelas.sum(:valor, :conditions => {:situacao => [Parcela::PENDENTE,
          Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA,
          Parcela::ENVIADO_AO_DR, Parcela::DEVEDORES_DUVIDOSOS_ATIVOS]})
    
    soma.round.to_i != soma_das_parcelas_pendentes
  end

  def self.pesquisa_simples(unidade_id, parametros, page = nil)
    @sqls = ["(recebimento_de_contas.unidade_id = ?)"]
    @variaveis = [unidade_id]
    ordem = parametros['ordem']

    unless parametros['pesquisa'].blank?
      @sqls << "(recebimento_de_contas.numero_de_controle LIKE ?)"
      @variaveis << parametros['pesquisa'].formatar_para_like
    end
    
    unless parametros['numero_de_renegociacoes'].blank?
      @sqls << "(recebimento_de_contas.numero_de_renegociacoes >= ?)"
      @variaveis << parametros['numero_de_renegociacoes']
    end
    
    unless parametros['texto'].blank?
      if ordem == 'situacao'
        @sqls << "(recebimento_de_contas.situacao = ? OR recebimento_de_contas.situacao_fiemt = ?)"
        2.times{@variaveis << parametros['texto']}
      else
        cpf_cnpj = parametros['texto'].gsub(/[\.\-\/]/, '')
        @sqls << "((recebimento_de_contas.numero_de_controle LIKE ?) OR (pessoas.nome LIKE ?) OR (pessoas.razao_social LIKE ?) OR (pessoas.cpf LIKE ?) OR (pessoas.cnpj LIKE ?) OR (servicos.descricao LIKE ?) OR (dependentes.nome LIKE ?) OR (pessoas.cpf LIKE ?) OR (pessoas.cnpj LIKE ?))"
        7.times{@variaveis << parametros['texto'].formatar_para_like}
        2.times{@variaveis << cpf_cnpj}
      end
    end
    ordem = 'recebimento_de_contas.situacao' unless ordem

    unless parametros['cartas'].blank?
      sql_para_cartas = []
      array_carta = []
      parametros['cartas'].each do |carta|
        array_carta << carta
      end
      if array_carta.include?('carta_1')
        sql_para_cartas << "(recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.data_primeira_carta IS NOT NULL)"
        @variaveis << unidade_id
      end
      if array_carta.include?('carta_2')
        sql_para_cartas << "(recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.data_segunda_carta IS NOT NULL)"
        @variaveis << unidade_id
      end
      if array_carta.include?('carta_3')
        sql_para_cartas << "(recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.data_terceira_carta IS NOT NULL)"
        @variaveis << unidade_id
      end
      @sqls << sql_para_cartas.join(' OR ')
    end

    preencher_array_para_campo_com_auto_complete parametros, :servico, 'recebimento_de_contas.servico_id'
    preencher_array_para_campo_com_auto_complete parametros, :cliente, 'recebimento_de_contas.pessoa_id'

    if parametros.blank?
      pesquisa = []
    else
      pesquisa = self.all(:include => [:pessoa, :servico, :dependente], :conditions => ([@sqls.join(' AND ')] + @variaveis), :order => ordem)
    end

    #    if parametros['emissao_cartas']
    #      case parametros['dias_de_atraso'].to_i
    #      when 0; dia_min = 0; dia_max = 36500
    #      when CARTA_1; dia_min = 20; dia_max = 45
    #      when CARTA_2; dia_min = 45; dia_max = 90
    #      when CARTA_3; dia_min = 90; dia_max = 36500
    #      end
    #      pesquisa.select do |recebimento|
    #        recebimento.parcelas.any? do |parcela|
    #          if parametros['numero_dias_atraso'].blank?
    #            parcela.verifica_situacoes && (Date.today - parcela.data_vencimento.to_date).numerator.between?(dia_min, dia_max)
    #          else
    #            dias_em_atraso = ((Date.today.to_datetime) - ((parcela.data_vencimento).to_date).to_datetime)
    #            dias_em_atraso = dias_em_atraso.to_i < 0 ? 0 : dias_em_atraso.to_i
    #            parcela.verifica_situacoes && (dias_em_atraso >= parametros['numero_dias_atraso'].to_i)
    #          end
    #        end
    #      end
    #    else
    pesquisa.paginate :page => page, :per_page => 50
    #    end
  end

  def self.vincular_carta(parametros = {})
    begin
      RecebimentoDeConta.transaction do
        recebimentos = []
        parametros['ids'].each do |id|
          recebimento = RecebimentoDeConta.find(id) rescue raise("Conta inválida!")
          case parametros['tipo_de_carta'].to_i
          when CARTA_1; recebimento.data_primeira_carta = Date.today
          when CARTA_2; recebimento.data_segunda_carta = Date.today
          when CARTA_3; recebimento.data_terceira_carta = Date.today
          end
          unless parametros['tipo']['cartas'].blank?
            HistoricoOperacao.cria_follow_up("Geração de carta de cobrança número #{parametros['tipo_de_carta']}",
              parametros['usuario'], recebimento, nil, parametros['tipo_de_carta'].to_i)
          else
            HistoricoOperacao.cria_follow_up("Geração de etiquetas do tipo #{parametros['etiqueta']}",
              parametros['usuario'], recebimento, nil, nil)
          end
          recebimento.vincular_carta = true
          recebimento.save false
          recebimentos << recebimento
          recebimento.vincular_carta = false
        end
        recebimentos
      end
    rescue Exception => e
      e.message
    end
  end

  def resumo_de_parcelas_atrasadas
    if self.unidade.unidade_mae_id.blank?
      self.parcelas.collect do |parcela|
        if (parcela.verifica_situacoes) && (parcela.data_vencimento.to_date < Date.today)
          [parcela.data_vencimento, (Date.today - parcela.data_vencimento.to_date).numerator, parcela.valor]
        end
      end.compact
    end
  end

  def self.pesquisa_renegociacoes(contar_ou_retornar,unidade_id,params)
    @sqls = []; @variaveis = []
    @sqls << "(recebimento_de_contas.unidade_id = ?)"; @variaveis << unidade_id
    @sqls << "(recebimento_de_contas.numero_de_renegociacoes > 0)"
    preencher_array_para_campo_com_auto_complete params, :servico, 'recebimento_de_contas.servico_id'
    preencher_array_para_campo_com_auto_complete params, :cliente, 'recebimento_de_contas.pessoa_id'
    preencher_array_para_campo_com_auto_complete params, :funcionario, 'recebimento_de_contas.cobrador_id'
    unless params['cliente_id'].blank?
      @sqls << '(pessoas.cliente = ?)'
      @variaveis << true
    end
    unless params['periodo_min'].blank? && params['periodo_max'].blank?
      preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'recebimento_de_contas.created_at'
    end
    self.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => :pessoa, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end


  def pode_cancelar?
    parc = self.parcelas
    numero_parcelas = parc.length
    i = 0
    parc.each do |p|
      if p.situacao == Parcela::QUITADA
        i+=1
      end
    end

    cartoes = []
    parc.each do |p| 
       unless p.cartoes.blank?
        p.cartoes.each do |c|
          cartoes << c
        end

       end
    end

    if i==numero_parcelas && cartoes.length > 0 && !cartoes.any?{|cartao| cartao.situacao == Cartao::GERADO}
      false
    else
      true
    end

  end

  def cancelar_contrato(usuario_corrente)#, data_cancelamento)
    RecebimentoDeConta.transaction do
      begin
        self.situacao = Cancelado
        self.situacao_fiemt = Inativo
        self.cancelado_pela_situacao_fiemt = true
        unless self.parcelas.collect(&:situacao).include?(Parcela::QUITADA)
          self.parcelas.each do |parcela|
            # Don't matter se a parcela foi cancelada pelo contrato ou não
            if parcela.situacao == Parcela::CANCELADA
              parcela.cancelado_pelo_contrato = true
              parcela.save!
              HistoricoOperacao.cria_follow_up("Mudando parcela nº #{parcela.numero} para cancelada pelo contrato", usuario_corrente, self)
            elsif parcela.verifica_situacoes
              parcela.situacao = Parcela::CANCELADA
              parcela.cancelado_pelo_contrato = true
              parcela.save!
              HistoricoOperacao.cria_follow_up("Cancelamento da parcela nº #{parcela.numero}", usuario_corrente, self)
            end
          end
          self.movimentos.each do |movimento|
            movimento.destroy
          end
          self.save!
          HistoricoOperacao.cria_follow_up("Contrato nº #{self.numero_de_controle} inativado", usuario_corrente, self)
          true
        else
          false
        end
      rescue Exception => e
        false
      end
    end
  end

  def estornar_contrato(usuario_corrente)
    RecebimentoDeConta.transaction do
      begin
        self.situacao = Normal
        self.situacao_fiemt = Normal
        self.cancelado_pela_situacao_fiemt = nil
        self.parcelas.each do |parcela|
          if parcela.situacao == Parcela::CANCELADA && parcela.cancelado_pelo_contrato == true
            parcela.situacao = Parcela::PENDENTE
            parcela.cancelado_pelo_contrato = nil
            parcela.save!
            HistoricoOperacao.cria_follow_up("Estorno da parcela nº #{parcela.numero}", usuario_corrente, self)
          end
        end
        self.save!
        HistoricoOperacao.cria_follow_up("Estorno do contrato nº #{self.numero_de_controle}", usuario_corrente, self)
        self.efetua_lancamento!
      rescue Exception => e
        false
      end
    end
  end

  def atribui_situacao_parcela(params)
    if params == Normal
      self.parcelas.each do|parc|
        if parc.verifica_situacoes
          parc.situacao = Parcela::PENDENTE
          parc.save!
        end
      end
    end
    if params == Juridico
      self.parcelas.each do|parc|
        if parc.verifica_situacoes
          parc.situacao = Parcela::JURIDICO
          parc.save!
        end
      end
    elsif params == Permuta
      self.parcelas.each do |parc|
        if parc.verifica_situacoes
          parc.situacao = Parcela::PERMUTA
          parc.save!
        end
      end
    elsif params == Baixa_do_conselho
      self.parcelas.each do |parc|
        if parc.verifica_situacoes
          parc.situacao = Parcela::BAIXA_DO_CONSELHO
          parc.save!
        end
      end
    elsif params == Desconto_em_folha
      self.parcelas.each do |parc|
        if parc.verifica_situacoes
          parc.situacao = Parcela::DESCONTO_EM_FOLHA
          parc.save!
        end
      end
    elsif params == Renegociado
      self.parcelas.each do |parc|
        if parc.verifica_situacoes
          parc.situacao = Parcela::RENEGOCIADA
          parc.save!
        end
      end
    end
  end

  def self.pesquisa_clientes_inadimplentes(contar_ou_retornar,unidade_id,params)
    @sqls = []; @variaveis = []
    @sqls << "(recebimento_de_contas.unidade_id = ?)"
    @variaveis << unidade_id

    @sqls << "(parcelas.data_da_baixa IS NULL AND parcelas.situacao IN (?) AND parcelas.data_vencimento < ?)"
    @variaveis << [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::ENVIADO_AO_DR]
    @variaveis << Date.today

    periodo_min = (params['periodo_min'].to_date rescue nil)
    periodo_max = (params['periodo_max'].to_date rescue nil)
    if periodo_min
      @sqls << "(parcelas.data_vencimento >= ?)"
      @variaveis << periodo_min
    end
    if periodo_max
      @sqls << "(parcelas.data_vencimento <= ?)"
      @variaveis << periodo_max
    elsif periodo_min.nil?
      @sqls << "(parcelas.data_vencimento < ?)"
      @variaveis << Date.today
    end
    unless params['cliente_id'].blank?
      @sqls << "(pessoas.id = ?)"
      @variaveis << params['cliente_id']
    end
    self.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:parcelas, :pessoa], :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end

  def criar_follow_up_update(object, usuario)
    mensagens = []
    mensagens << "Conta a Receber Alterada"
    mensagens << "A Conta Contábil Receita foi alterada de '#{object.conta_contabil_receita.codigo_contabil} - #{object.conta_contabil_receita.nome}' para '#{self.conta_contabil_receita.codigo_contabil} - #{self.conta_contabil_receita.nome}'" if  self.conta_contabil_receita_id != object.conta_contabil_receita_id
    mensagens << "A Unidade Organizacional foi alterada de '#{object.unidade_organizacional.codigo_da_unidade_organizacional} - #{object.unidade_organizacional.nome}' para '#{self.unidade_organizacional.codigo_da_unidade_organizacional} - #{self.unidade_organizacional.nome}'" if  self.unidade_organizacional_id != object.unidade_organizacional_id
    mensagens << "O Centro foi alterado de '#{object.centro.codigo_centro} - #{object.centro.nome}' para '#{self.centro.codigo_centro} - #{self.centro.nome}'" if  self.centro_id != object.centro_id
    mensagens.each do |mensagem|
      HistoricoOperacao.cria_follow_up(mensagem, usuario, self)
    end
  end

  def self.procura_o_indice(array, elemento)
    array.each_with_index do |sub_array, index|
      if sub_array.first == elemento
        return index
      end
    end
    nil
  end

  def parcelas_ordenadas_numero
    self.parcelas.sort_by {|a| a.numero.nil? ? a.numero_parcela_filha.real.to_f : a.numero.real.to_f}
  end

  def parcelas_ordenadas_vencimento
    self.parcelas.sort_by {|a| a.data_vencimento.to_date}
  end

  def realiza_cancelamento_de_contrato(params, usuario_corrente)
    begin
      RecebimentoDeConta.transaction do
        if self.situacao != Cancelado
          if params['data_cancelamento'].blank?
            return ['', "O campo data de cancelamento deve ser preenchido."]
          else
            if params['justificativa'].blank?
              return ['', "O campo justificativa deve ser preenchido."]
            else
              self.situacao = Cancelado
              self.data_cancelamento = params['data_cancelamento']
              self.save!
              HistoricoOperacao.cria_follow_up("Contrato cancelado em #{params['data_cancelamento']}", usuario_corrente, self, params['justificativa'])
              self.parcelas.each do |parcela|
                parcela.situacao = Parcela::CANCELADA
                parcela.save!
              end
              return [true, "O contrato #{self.numero_de_controle} foi cancelado!"]
            end
          end
        end
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def self.pesquisa_para_analise_de_contrato(unidade_id, params, servico = nil)
    @variaveis = []
    @sqls = []
    #    situacoes = [Normal, Juridico, Renegociado, Permuta, Baixa_do_conselho, Desconto_em_folha, Enviado_ao_DR,
    #      Devedores_Duvidosos_Ativos]

    @sqls << '(recebimento_de_contas.unidade_id = ?)'
    @variaveis << unidade_id
    #    @sqls << '(recebimento_de_contas.situacao_fiemt IN (?))'
    #    @variaveis << situacoes
    @sqls << '(recebimento_de_contas.situacao_fiemt NOT IN (?))'
    @variaveis << [Cancelado, Evadido, Inativo]    
    @sqls << '(recebimento_de_contas.situacao NOT IN (?))'
    @variaveis << [Cancelado, Evadido, Inativo]
    @sqls << '((recebimento_de_contas.contabilizacao_da_receita = ?) OR (recebimento_de_contas.contabilizacao_da_receita IS NULL))'
    @variaveis << false
    @sqls << '(recebimento_de_contas.provisao = ?)'
    @variaveis << SIM

    unless servico == nil
      @sqls << '(recebimento_de_contas.servico_iniciado = ?)'
      @variaveis << servico
    end

    if params['mes'] != '0'
      data_inicio = Date.new(params["ano"].to_i, params['mes'].to_i, 1)
      data_fim = data_inicio.at_end_of_month
      @sqls << '(recebimento_de_contas.data_inicio_servico <= ? AND recebimento_de_contas.data_final_servico >= ?)'
      @variaveis << data_fim
      @variaveis << data_inicio
    end

    if !params['ano'].blank?
      @sqls << "(YEAR(recebimento_de_contas.data_inicio_servico) <= ?) AND (YEAR(recebimento_de_contas.data_final_servico) >= ?)"
      @variaveis << params['ano']
      @variaveis << params['ano']
    end

    #@sqls << 'recebimento_de_contas.id IN(2743)'
    #@sqls << 'recebimento_de_contas.id NOT IN(13452)'
    #@sqls << 'recebimento_de_contas.id IN(13452)'
    #@sqls << 'recebimento_de_contas.id IN(6873)'
    #@sqls << 'recebimento_de_contas.id IN(6407)'
    #@sqls << 'recebimento_de_contas.id IN(32830)'
    #@sqls << 'recebimento_de_contas.id IN(27002)'
    #@sqls << 'recebimento_de_contas.id IN(38110)'
    
    
    #ESTRANHO
    #@sqls << 'recebimento_de_contas.id IN(1702)'
    
    RecebimentoDeConta.all :conditions => [@sqls.join(" AND ")] + @variaveis, :include => :servico, :order => 'servicos.descricao ASC'#, :limit => 70
  end



  def self.pesquisa_contratos_contabilizados(contar_ou_retornar, unidade_id, params)
    @variaveis = []
    @sqls = []

    @sqls << '(recebimento_de_contas.unidade_id = ?)'
    @variaveis << unidade_id

		@sqls << '(recebimento_de_contas.contabilizacao_da_receita IS NULL OR recebimento_de_contas.contabilizacao_da_receita = ?)'
		@variaveis << false


    @sqls << 'YEAR(recebimento_de_contas.data_inicio_servico) = ?'
    @variaveis << params["ano"]

    @sqls << 'MONTH(recebimento_de_contas.data_inicio_servico) = ?'
    @variaveis << params["mes"]

    @sqls << 'recebimento_de_contas.conta_contabil_receita_id = ?'
    @variaveis << params["conta_contabil_id"].split("_").last rescue nil

    @sqls << 'recebimento_de_contas.provisao = ?'
    @variaveis << '1'

    self.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:movimentos, :servico, :pessoa, :unidade_organizacional, :centro, :conta_contabil_receita], :order => 'pessoas.nome ASC, pessoas.razao_social ASC, recebimento_de_contas.numero_de_controle ASC')
  end




  def self.pesquisa_contabilizacao_receitas(contar_ou_retornar, unidade_id, params, ano)
    @variaveis = []
    @sqls = []

    @sqls << '(recebimento_de_contas.unidade_id = ?) AND (movimentos.tipo_lancamento = ?)'
    @variaveis << unidade_id
    @variaveis << 'C'

    numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
    @sqls << 'YEAR(movimentos.data_lancamento) = ?'
    @variaveis << ano

    @sqls << '(recebimento_de_contas.situacao_fiemt NOT IN (?))'
    @variaveis << [Cancelado, Evadido]

    if numero_mes.include?(params["mes"])
      data = Date.new(ano, params["mes"].to_i, 1)
      @sqls << '(movimentos.data_lancamento >= ?) AND (movimentos.data_lancamento <= ?)'
      @variaveis << data
      @variaveis << data.end_of_month
    end

    ordenacao = []

    1.upto(5) do |i|
      if !params["ordenacao_#{i}"].blank?
        ordenacao << params["ordenacao_#{i}"]
      end
    end

    self.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:movimentos, :servico, :pessoa, :unidade_organizacional, :centro, :conta_contabil_receita], :order => ordenacao.blank? ? 'recebimento_de_contas.id' : ordenacao.join(','))
  end

  def porcentagem_contabilizacao_receitas(ano, mes)
    data = Date.new(ano, mes.to_i, 1)
    movimento = self.movimentos.collect{|mov| mov if mov.data_lancamento.to_date <= data.end_of_month && mov.tipo_lancamento == 'C' && !mov.lancamento_inicial}
    objeto = movimento.blank? ? 0 : movimento.compact.first
    valor_movimento = objeto.valor_total.real.to_f rescue 0
    porcentagem = (valor_movimento * 100.0) / self.valor_original
    format('%.2f', porcentagem)
  end

  def self.pesquisa_contratos_vendidos(contar_ou_retornar,unidade_id, params)
    @variaveis = []
    @sqls = []
    if (!params[:periodo_min].blank? && !params[:periodo_max].blank? )
      @sqls << '(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_inicio between ? AND ?)'
      @variaveis << unidade_id
      @variaveis << params[:periodo_min].to_date
      @variaveis << params[:periodo_max].to_date
    end

    unless (params[:tipo].blank?)
      unless params[:tipo] == "2"
        @sqls << '(recebimento_de_contas.provisao = ?) '
        @variaveis << params[:tipo]
      else
        @sqls << '(recebimento_de_contas.provisao IN (0,1)) '
      end
    end
    recebimentos = RecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:pessoa], :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
    recebimentos
  end

  def self.contratos_cancelados(contar_ou_retornar, unidade_id, params, ano)
    @variaveis = []
    @sqls = []
    cancelados_evadidos = []
    if (!params[:periodo_min].blank? && !params[:periodo_max].blank? )
      @sqls << '(recebimento_de_contas.provisao = 1 AND recebimento_de_contas.unidade_id = ?) AND ((recebimento_de_contas.situacao_fiemt = ? AND recebimento_de_contas.data_cancelamento BETWEEN ? AND ? ) OR (recebimento_de_contas.situacao_fiemt = ? AND recebimento_de_contas.data_evasao BETWEEN ? AND ?)) '
      @variaveis << unidade_id
      @variaveis << RecebimentoDeConta::Cancelado
      @variaveis << params[:periodo_min].to_date
      @variaveis << params[:periodo_max].to_date
      @variaveis << RecebimentoDeConta::Evadido
      @variaveis << params[:periodo_min].to_date
      @variaveis << params[:periodo_max].to_date
    
    end
    cancelados_evadidos = RecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:movimentos, :pessoa], :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
    cancelados_evadidos
  end


  def self.faturamento_clientes(contar_ou_retornar, unidade_id, params, ano)
    @variaveis = []
    @sqls = []


    #@sqls << '(recebimento_de_contas.unidade_id = ?)'
    #@sqls << unidade_id


    @sqls << '((recebimento_de_contas.unidade_id = ?) AND YEAR(movimentos.data_lancamento) = ? AND
              (movimentos.tipo_lancamento = ?) AND (movimentos.lancamento_inicial IS NULL))'
    @variaveis << unidade_id
    @variaveis << ano
    @variaveis << 'C'



    
    numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
    if numero_mes.include?(params['mes'])
      data = Date.new(ano, params['mes'].to_i, 1)

      @sqls << '(
                  (movimentos.data_lancamento BETWEEN ? AND ? AND recebimento_de_contas.situacao_fiemt NOT IN (?)) OR
                  (movimentos.created_at > ? AND recebimento_de_contas.situacao_fiemt IN (?))
                )'
      @variaveis << data
      @variaveis << data.end_of_month
      @variaveis << [Cancelado, Evadido]
      @variaveis << data.end_of_month
      @variaveis << [Cancelado, Evadido]

      @sqls << '((recebimento_de_contas.data_inicio <= ?) OR (recebimento_de_contas.data_inicio_servico <= ?))'
      @variaveis << data.end_of_month
      @variaveis << data.end_of_month
    end
    #p "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
    #p [@sqls.join(' AND ')] + @variaveis
    
    # @sqls << "(MONTH(recebimento_de_contas.data_cancelamento) <> #{params['mes'].to_i})"
    faturados = RecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:movimentos, :pessoa], :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
    #p "**************"
    #p faturados
    if faturados.is_a?(Array)
      faturados = faturados.delete_if {|f|  !f.data_cancelamento.blank? && f.data_cancelamento.to_date >= data.to_date && f.data_cancelamento.to_date <= data.end_of_month.to_date }
    end
    #-------
    #p "Passei"
    @variaveis = []
    @sqls = []
    @sqls << '(recebimento_de_contas.unidade_id = ?) AND (movimentos.lancamento_inicial IS NOT NULL)'
    @variaveis << unidade_id

    numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
    if numero_mes.include?(params['mes'])
      data = Date.new(ano, params['mes'].to_i, 1)
      @sqls << '(recebimento_de_contas.data_inicio_servico > ?) AND (recebimento_de_contas.data_inicio <= ?)'
      @variaveis << data.end_of_month
      @variaveis << data.end_of_month
      # @sqls << '(recebimento_de_contas.data_cancelamento NOT BETWEEN ? AND ?)'
      #  @variaveis << data
      #  @variaveis << data.end_of_month
    end
    antigos = RecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:movimentos, :pessoa], :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
    if antigos.is_a?(Array)
      antigos = antigos.delete_if {|f|  !f.data_cancelamento.blank? && f.data_cancelamento.to_date >= data.to_date && f.data_cancelamento.to_date <= data.end_of_month.to_date }
    end
    #p "****ANTIGOS**********"
    #p antigos

    faturados + antigos
  end

  def self.pesquisar_contratos_para_inicio_em_lote(params, unidade_id, ano)
    return [] if params.blank?
    @variaveis = []
    @sqls = []

    @sqls << '(unidade_id = ?) AND (servico_iniciado = ?)'
    @variaveis << unidade_id
    @variaveis << false

    situacoes = [Normal, Juridico, Renegociado, Permuta, Baixa_do_conselho, Desconto_em_folha, Enviado_ao_DR,
      Devedores_Duvidosos_Ativos]
    @sqls << '(recebimento_de_contas.situacao_fiemt IN (?))'
    @variaveis << situacoes
    @sqls << '(recebimento_de_contas.situacao = ?)'
    @variaveis << Normal

    preencher_array_para_campo_com_auto_complete params, :servico, 'servico_id'

    numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
    if numero_mes.include?(params['mes'])
      data = Date.new(ano, params['mes'].to_i, 1)
      @sqls << '(data_inicio_servico <= ? AND data_final_servico >= ?)'
      @variaveis << data.end_of_month
      @variaveis << data
    end

    RecebimentoDeConta.find(:all, :conditions => [@sqls.join(' AND ')] + @variaveis)
  end

  def self.iniciar_servicos_em_lote(params, unidade_id, ano)
    params ||= {}
    begin
      RecebimentoDeConta.transaction do
        unless params['ids'].blank?
          params['ids'].each do |id|
            unidade = Unidade.find unidade_id rescue raise 'Unidade inválida!'
            contrato = RecebimentoDeConta.find id, :conditions => ["(unidade_id = ? AND servico_iniciado = ?)", unidade.id, false] rescue raise("Você selecionou contratos inválidos. Verifique!")
            contrato.ano_contabil_atual = ano
            contrato.servico_iniciado = true
            contrato.servico_alguma_vez_iniciado = true
            contrato.iniciando_servicos = true
            contrato.save #|| raise("Não foi possível iniciar os serviços!\n\n#{contrato.errors.full_messages.join("\n")}")
            contrato.iniciando_servicos = false
          end
        else
          raise 'Selecione pelo menos um contrato para executar o início dos serviços!'
        end
        [true, params['ids'].length > 1 ? 'Serviços iniciados com sucesso!' : 'Serviço iniciado com sucesso!']
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def reajustar_contrato(params)
    begin
      RecebimentoDeConta.transaction do
        data_do_reajuste = params['data_reajuste'].to_date
        data_final_para_busca = Date.new(2100, 12, 31)
        parcelas = self.parcelas.collect{|parcela| parcela if parcela.situacao == Parcela::PENDENTE && parcela.data_vencimento.to_date >= Date.today && parcela.data_vencimento.to_date.between?(data_do_reajuste, data_final_para_busca.to_date)}.compact
        raise 'Não é possível reajustar este contrato, pois não existem parcelas com a situação Vincenda' if parcelas.blank?
        valor_do_reajuste = (params['valor_reajuste'].real.to_f * 100).to_i
        acrescimo_para_parcela = valor_do_reajuste / parcelas.length
        parcelas.each_with_index do |parcela, index|
          parcela.valor += acrescimo_para_parcela
          if index == (parcelas.length - 1)
            if valor_do_reajuste > (acrescimo_para_parcela * parcelas.length)
              diferenca = valor_do_reajuste - (acrescimo_para_parcela * parcelas.length)
              parcela.valor += diferenca
            end
          end
          if self.rateio == 1
            atributos = {:valor => parcela.valor, :data_vencimento => parcela.data_vencimento}
            refaz_proporcionalmente_o_rateio(atributos, parcela)
            resultado = parcela.grava_itens_do_rateio(self.ano_contabil_atual, self.usuario_corrente, true)
            if resultado.first != true
              raise "#{resultado.last}"
            end
          end
          parcela.save!
        end
        reajuste = Reajuste.new(:data_reajuste => data_do_reajuste, :valor_reajuste => valor_do_reajuste,
          :conta => self, :usuario => self.usuario_corrente)
        reajuste.save || raise("Não foi possível gravar o reajuste deste contrato:\n#{reajuste.errors.full_messages.join("\n")}")

        centro = Centro.first(:conditions => ["(codigo_centro LIKE ?) AND (ano = ?) AND (entidade_id = ?)", '9%', self.ano_contabil_atual, self.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
        unidade_organizacional = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional LIKE ?) AND (ano = ?) AND (entidade_id = ?)", '9%', self.ano_contabil_atual, self.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

        lancamento_debito = [{:tipo => 'D', :unidade_organizacional => unidade_organizacional,
            :plano_de_conta => self.unidade.parametro_conta_valor_cliente(self.ano_contabil_atual).conta_contabil,
            :centro => centro, :valor => valor_do_reajuste}]
        lancamento_credito = [{:tipo => 'C', :unidade_organizacional => unidade_organizacional,
            :plano_de_conta => self.unidade.parametro_conta_valor_faturamento(self.ano_contabil_atual).conta_contabil,
            :centro => centro, :valor => valor_do_reajuste}]

        Movimento.lanca_contabilidade(self.ano_contabil_atual, [
            {:conta => self, :historico => "#{self.historico} (Reajuste)", :numero_de_controle => self.numero_de_controle,
              :data_lancamento => data_do_reajuste, :tipo_lancamento => 'J', :tipo_documento => self.tipo_de_documento,
              :provisao => Movimento::PROVISAO, :pessoa_id => self.pessoa_id},
            lancamento_debito, lancamento_credito], self.unidade_id)
      end
      [true, 'Contrato reajustado com sucesso!']
    rescue Exception => e
      #      p e.message
      [false, e.message]
    end
  end

  def nao_permite_alteracao?
    self.abdicando = self.abdicando.blank? ? true : false
    self.evadindo = self.evadindo.blank? ? true : false
    if self.provisao == NAO && self.situacao_fiemt == Cancelado && !self.abdicando && !self.evadindo
      true
    else
      false
    end
  end

  def contrato_ja_contabilizado?
    retorno = Movimento.find(:first, :conditions => ['tipo_lancamento = ? AND conta_type = ? AND conta_id = ?', 'C', 'RecebimentoDeConta', self.id])
    retorno.blank? ? false : true
  end

  def estornar_renegociacao(data_estorno, usuario_corrente, justificativa)
    return [false, 'O campo Data do Estorno deve ser preenchido'] if data_estorno.blank?
    return [false, 'O campo Justificativa deve ser preenchido'] if justificativa.blank?
    RecebimentoDeConta.transaction do
      begin
        historico_follow_up = HistoricoOperacao.find(:first, :conditions => ['conta_id = ? AND conta_type = ? AND descricao LIKE ?', self.id, 'RecebimentoDeConta', 'Geradas%'])
        numero_de_parcelas = historico_follow_up.descricao.split("\s")[1].to_i
        p "NÚMERO DE PARCELASSSSSSS"
        p numero_de_parcelas
        self.valor_do_documento = self.valor_original
        self.numero_de_parcelas = numero_de_parcelas
        self.renegociando = true
        self.save false
        self.renegociando = false
        #data_parcela_renegociada = self.parcelas.collect{|p| p.created_at if p.situacao == Parcela::RENEGOCIADA}.compact.first
        self.parcelas.each do |parc|
          if parc.situacao == Parcela::RENEGOCIADA && (parc.numero.to_i < numero_de_parcelas || parc.numero_parcela_filha.to_i < numero_de_parcelas)
            parc.situacao = Parcela::PENDENTE
            p "Volta para pendente"
            p parc.numero
            parc.save false
          else
            if parc.situacao == Parcela::PENDENTE && (parc.numero.to_i > numero_de_parcelas || parc.numero_parcela_filha.to_i > numero_de_parcelas)
             parc.destroy
             p "É excluídaaaa"
             p parc.numero
            end
            #nao voltar isto daqui parc.destroy if parc.situacao == Parcela::PENDENTE && data_parcela_renegociada.to_date > parc.created_at.to_date
          end
        end
        movimentos_renegociacao = self.movimentos.collect{|mov| mov if mov.historico.include?('Renegociação')}.compact
        movimentos_renegociacao.each do |mov_ren|
          mov_estorno_reneg = mov_ren.clone
          mov_estorno_reneg.historico = self.historico + ' (Cancelamento de Renegociação)'
          mov_estorno_reneg.tipo_lancamento = 'H'
          mov_estorno_reneg.data_lancamento = data_estorno.to_date
          mov_ren.itens_movimentos.each do |item|
            mov_estorno_reneg.itens_movimentos << item.clone
          end
          mov_estorno_reneg.itens_movimentos.each do |it|
            it.tipo = (it.tipo == 'C') ? 'D' : 'C'
            it.save!
          end
          mov_estorno_reneg.save!
         #true
        end
        HistoricoOperacao.cria_follow_up('Estorno de Renegociação efetuado', usuario_corrente, self, justificativa)
        [true, 'O contrato ' "#{self.numero_de_controle}" ' teve sua renegociação estornada!']
      rescue Exception => e
        [false, e.message]
      end
    end
  end

  def self.importar_arquivo_xml(arquivo_xml, unidade_sessao, current_usuario, ano_contabil)
    exceptions = ''
    begin
      RecebimentoDeConta.transaction do        
        return [false, 'Deve ser inserido um arquivo para a importação!'] if arquivo_xml.blank?
        begin
          xml = Hash.from_xml(arquivo_xml)
        rescue
          return [false, 'Formato do arquivo inválido!']
        end
        if xml['contratos']
          unidade = Unidade.find(unidade_sessao)
          Dir.mkdir(RAILS_ROOT + '/log/importacao_contratos', 0777) rescue nil
          Dir.mkdir(RAILS_ROOT + "/log/importacao_contratos/#{unidade.nome}", 0777) rescue nil
          log_importacao = RAILS_ROOT + "/log/importacao_contratos/#{unidade.nome}/importacao_contas_a_receber_#{Time.now.strftime '%y_%m_%d'}.txt"
          File.new(log_importacao, 'w', 0777)
          #File.chmod(777, log_importacao)

          xml['contratos']['recebimento_de_conta'].each do |contrato|
            recebimento = RecebimentoDeConta.find_by_numero_de_controle(contrato['numero_de_controle'])
            if recebimento.blank?
              recebimento = RecebimentoDeConta.new
            end

            #RELACIONAMENTOS
            #unidade = Unidade.find_by_nome(contrato['unidade']['nome'])
            servico = Servico.find_by_unidade_id_and_descricao(unidade.id, contrato['servico'])
            cliente = Pessoa.find(:first, :conditions => ["REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), '/', '') = ? OR REPLACE(REPLACE(REPLACE(cnpj, '.', ''), '-', ''), '/', '') = ?", contrato['cliente']['cpf_cnpj'], contrato['cliente']['cpf_cnpj']])
            if cliente.blank?
              cliente = Pessoa.new
              cliente.unidade = unidade
              cliente.entidade = unidade.entidade
              if contrato['cliente']['cpf_cnpj'].length == 11
                cliente.tipo_pessoa = Pessoa::FISICA
                cliente.cpf = contrato['cliente']['cpf_cnpj']
                cliente.nome = contrato['cliente']['nome_razao']
                cliente.data_nascimento = contrato['cliente']['data_nascimento']
              elsif contrato['cliente']['cpf_cnpj'].length == 14
                cliente.tipo_pessoa = Pessoa::JURIDICA
                cliente.cnpj = contrato['cliente']['cpf_cnpj']
                cliente.razao_social = contrato['cliente']['nome_razao']
                cliente.contato = contrato['cliente']['contato']
              end
              cliente.cliente = true
              cliente.rg_ie = contrato['cliente']['rg_ie']
              cliente.cep = contrato['cliente']['cep']
              cliente.endereco = contrato['cliente']['endereco']
              cliente.numero = contrato['cliente']['numero']
              cliente.bairro = contrato['cliente']['bairro']
              cliente.telefone = contrato['cliente']['telefone'].split(',')
              cliente.localidade = Localidade.find(:first, :conditions => ['nome = ? AND uf = ?', contrato['cliente']['cidade'], contrato['cliente']['uf']])
              cliente.email = contrato['cliente']['email'].split(',')
              cliente.industriario = contrato['cliente']['industriario'].upcase == 'SIM' ? Pessoa::SIM : Pessoa::NAO
              if cliente.valid?
                cliente.save
              else
                exceptions += "Problemas no cliente: #{contrato['cliente']['cpf_cnpj']} - #{contrato['cliente']['nome_razao']}\n\n"
                exceptions += cliente.errors.full_messages.collect{|erro| "* #{erro}"}.join("\n")
                exceptions += "\n\n"
                exceptions += '-----------------------------------------------------------------------------------------------'
                exceptions += '--------------------------------------------------------------------'
                exceptions += "\n\n"
              end
            end

            if exceptions.blank?
              dependente = Dependente.find_by_pessoa_id_and_nome(cliente.id, contrato['dependente']['nome'])
              if dependente.blank? && !contrato['dependente']['nome'].blank?
                dependente = Dependente.new
                dependente.nome = contrato['dependente']['nome']
                dependente.nome_da_mae = contrato['dependente']['nome_mae'] unless contrato['dependente']['nome_mae'].blank?
                dependente.nome_do_pai = contrato['dependente']['nome_pai'] unless contrato['dependente']['nome_pai'].blank?
                dependente.data_de_nascimento = contrato['dependente']['data_nascimento'] unless contrato['dependente']['data_nascimento'].blank?
                dependente.pessoa = cliente
                if dependente.valid?
                  dependente.save
                else
                  exceptions += "Problemas no dependente: #{contrato['dependente']['nome']}, do cliente #{contrato['cliente']['nome_razao']}\n\n"                
                  exceptions += dependente.errors.full_messages.collect{|erro| "* #{erro}"}.join("\n")
                  exceptions += "\n\n"
                  exceptions += '-----------------------------------------------------------------------------------------------'
                  exceptions += '--------------------------------------------------------------------'
                  exceptions += "\n\n"
                end
              end
            end

            if exceptions.blank?
              conta_contabil_receita = PlanoDeConta.find_by_codigo_contabil_and_ano(contrato['conta_contabil_receita']['codigo'], contrato['conta_contabil_receita']['ano'])
              unidade_organizacional = UnidadeOrganizacional.find_by_codigo_da_unidade_organizacional_and_ano(contrato['unidade_organizacional']['codigo'], contrato['unidade_organizacional']['ano'])
              centro = Centro.find_by_codigo_centro_and_ano(contrato['centro']['codigo'], contrato['centro']['ano'])
              vendedor = Pessoa.find(:first, :conditions => ["REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), '/', '') = ? OR REPLACE(REPLACE(REPLACE(cnpj, '.', ''), '-', ''), '/', '') = ?", contrato['vendedor']['cpf'], contrato['vendedor']['cpf']])
              cobrador = Pessoa.find(:first, :conditions => ["REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), '/', '') = ? OR REPLACE(REPLACE(REPLACE(cnpj, '.', ''), '-', ''), '/', '') = ?", contrato['cobrador']['cpf'], contrato['cobrador']['cpf']])

              #recebimento.numero_de_controle = contrato['numero_de_controle']
              recebimento.tipo_de_documento = contrato['tipo_de_documento']
              recebimento.numero_nota_fiscal = contrato['numero_nota_fiscal']
              recebimento.data_inicio = contrato['data_inicio']
              recebimento.data_final = contrato['data_final']
              recebimento.data_inicio_servico = contrato['data_inicio_servico']
              recebimento.data_final_servico = contrato['data_final_servico']
              recebimento.data_venda = contrato['data_venda']
              recebimento.ano = contrato['ano']
              recebimento.dia_do_vencimento = contrato['dia_do_vencimento']
              recebimento.valor_do_documento = contrato['valor_do_documento']
              recebimento.valor_original = contrato['valor_original']
              recebimento.numero_de_parcelas = contrato['numero_de_parcelas']
              recebimento.vigencia = contrato['vigencia']
              recebimento.rateio = contrato['rateio']
              recebimento.provisao = contrato['provisao']
              recebimento.multa_por_atraso = contrato['multa_por_atraso']
              recebimento.juros_por_atraso = contrato['juros_por_atraso']
              recebimento.origem = contrato['origem']
              recebimento.historico = contrato['historico']
              recebimento.unidade = unidade
              recebimento.servico = servico
              recebimento.pessoa = cliente
              recebimento.dependente = dependente
              recebimento.conta_contabil_receita = conta_contabil_receita
              recebimento.unidade_organizacional = unidade_organizacional
              recebimento.centro = centro
              recebimento.vendedor = vendedor
              recebimento.cobrador = cobrador
              recebimento.usuario_corrente = current_usuario
              recebimento.ano_contabil_atual = ano_contabil
              if recebimento.save
                recebimento.efetua_lancamento! if recebimento.provisao == RecebimentoDeConta::SIM
                recebimento.gerar_parcelas(recebimento.ano)
                #PARCELAS
                #              if contrato['parcelas']
                #                if contrato['parcelas']['parcela'].is_a?(Array)
                #                contrato['parcelas']['parcela'].each do |parc|
                #                  p parc
                #                  parcela = Parcela.find_by_conta_id_and_conta_type_and_numero(recebimento.id, 'RecebimentoDeConta', parc['numero'])
                #                  if parcela.blank?
                #                    parcela = Parcela.new
                #                  end
                #                  parcela.numero = parc['numero']
                #                  parcela.valor = parc['valor']
                #                  parcela.data_vencimento = parc['data_vencimento']
                #                  parcela.situacao = recebimento.atribui_situacao
                #                  parcela.conta_id = recebimento.id
                #                  parcela.conta_type = 'RecebimentoDeConta'
                #                  if parcela.save
                #                  else
                #                    exceptions += "Problemas na parcela #{parc['numero']} do contrato #{contrato['numero_de_controle']}\n\n"
                #                    exceptions += parcela.errors.full_messages.collect{|erro| "* #{erro}"}.join("\n")
                #                    exceptions += "\n\n"
                #                    exceptions += '-----------------------------------------------------------------------------------------------'
                #                    exceptions += '--------------------------------------------------------------------'
                #                    exceptions += "\n\n"
                #                  end
                #                end
                #              else
                #                return [false, 'Estrutura do arquivo inválido na seção de parcelas']
                #              end
              else
                exceptions += "Problemas no contrato: #{contrato['numero_de_controle']}\n\n"
                exceptions += recebimento.errors.full_messages.collect{|erro| "* #{erro}"}.join("\n")
                exceptions += "\n\n"
                exceptions += '-----------------------------------------------------------------------------------------------'
                exceptions += '--------------------------------------------------------------------'
                exceptions += "\n\n"
              end
            end
          end

          File.open log_importacao, 'w' do |f|
            f.puts exceptions
          end
          if exceptions.blank?
            #File.unlink(log_importacao)
            [true, 'Importação finalizada com sucesso']
          else
            logname = "importacao_contas_a_receber_#{Time.now.strftime '%y_%m_%d'}.txt"
            [false, "Importação finalizada com erros. Verifique os logs da aplicação no arquivo [#{logname}] disponível na pasta de sua unidade"]
          end
        else
          [false, 'Estrutura do arquivo inválido!']
        end
      end
    rescue Exception => e
      #p e.message
      #LANCAMENTOS_LOGGER.erro e.backtrace.join("\n")
      [false, e.message]
    end
  end

end
