class Movimento < ActiveRecord::Base

  acts_as_audited

  #CONSTANTES
  BAIXA = 0
  PROVISAO = 1
  SIMPLES = 3

  # TIPOS DE LANCAMENTO
  # A - TROCA DE FORMA DE PAGAMENTO
  # B - CANCELAMENTO DE PARCELA DE CONTRATO CANC/EVADIDO
  # C - CONTABILIZAÇÃO DE RECEITAS
  # D - LANÇAMENTO DE ESTORNO DA ABDICAÇÃO
  # E - ENTRADA
  # F - ESTORNO DE CHEQUE BAIXADO
  # G - ESTORNO DE RENEGOCIAÇÃO (Evasão) --> NÃO EXISTE MAIS (AGORA É SÓ O H)
  # H - ESTORNO DE RENEGOCIAÇÃO (Cancelamento) --> EXISTE PARA ESTORNOS DE RENEGOCIAÇÃO EM GERAL
  # I - ESTORNO DE CARTÃO BAIXADO
  # J - REAJUSTE
  # K - ESTORNO DE BAIXA DE PARCELA
  # L - ESTORNO DE CHEQUE DEVOLVIDO
  # M - ESTORNO DE CHEQUE REAPRESENTADO
  # N - ESTORNO DE PAGAMENTOS
  # O - REVERSÃO DE EVASÃO
  # R - BAIXA DE CARTAO
  # S - SAÍDA
  # T - LANÇAMENTO DE ESTORNO DA EVASÃO
  # U - LANÇAMENTO DE ESTORNO MANUAL
  # V - REVERSÃO DE CANCELAMENTO
  # Z - CONTABILIZAÇÃO DE RECEITAS - REAJUSTE

  #VALIDAÇÕES
  validates_presence_of :conta, :message => 'deve ser preenchida', :if => Proc.new{|objeto| objeto.provisao != SIMPLES}
  validates_presence_of :historico, :data_lancamento, :pessoa, :provisao, :message => 'é inválido.'
  validates_presence_of :unidade, :message => 'é inválida.'
  validates_inclusion_of :tipo_lancamento, :in => ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'R', 'S', 'T', 'U', 'V', 'Z'], :message => 'é inválido.'
  validates_inclusion_of :tipo_documento, :in => PagamentoDeConta::TIPOS_DE_DOCUMENTO.collect(&:last), :message => 'é inválido.'

  #RELACIONAMENTOS
  has_many :itens_movimentos, :dependent => :destroy
  has_many :historico_operacoes, :dependent => :destroy
  belongs_to :pessoa
  belongs_to :unidade
  belongs_to :conta, :polymorphic => true
  belongs_to :parcela
  
  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  attr_accessor :lancamento_simples, :destruindo
  attr_writer :valor_do_documento_em_reais
  data_br_field :data_lancamento
  converte_para_data_para_formato_date :data_lancamento
  cria_readers_e_writers_para_o_nome_dos_atributos :pessoa

  HUMANIZED_ATTRIBUTES = {
    :historico => 'O campo histórico',
    :data_lancamento => 'O campo data de lançamento',
    :tipo_lancamento => 'O campo tipo de lançamento',
    :pessoa => 'O campo cliente/fornecedor'
  }

  def initialize(attributes = {})
    attributes['data_lancamento'] ||= Date.today
    attributes['provisao'] ||= SIMPLES
		self.destruindo = false
    super
  end

  def tipo_lancamento_verbose
    tipo_lancamento == 'E' ? 'Entrada' : 'Saída'
  end

  def provisao_verbose
    case provisao
    when BAIXA; 'Pago/Baixado'
    when PROVISAO; 'Provisão'
    when SIMPLES; 'Simples'
    end
  end

  def valor_do_documento_em_reais
    (valor_total.real.to_f / 100).real.to_s
  end

  def after_validation
    if self.liberacao_dr_faixa_de_dias_permitido == true
      self.liberacao_dr_faixa_de_dias_permitido = false
    end
  end

  def validate
    if self.liberacao_dr_faixa_de_dias_permitido != true && self.provisao == Movimento::SIMPLES
     if self.data_lancamento.to_date > Date.today
            errors.add :data_lancamento, 'não pode ser futura'
     end
    if !data_de_lancamento_valida? && !validar_data_inicio_entre_limites
        errors.add :data_lancamento, 'excedeu o limite máximo permitido'
      end
    end

    erro = self.errors.instance_variable_get(:@errors)
    if erro.has_key?('itens_movimentos')
      erro.delete 'itens_movimentos'
      array_erros = []
      erro['base'].each { |i| array_erros << i }  if erro['base']
      erro.delete 'base'
      self.itens_movimentos.each { |i| i.errors.full_messages.each { |e| array_erros << e } }
      erro['base'] = array_erros
    end
    erro['base'].uniq! if erro.has_key?('base')
  end

  def limpa_dados_vazios
    lancamento_simples.each_pair { |key, value| lancamento_simples[key.to_s.sub('_nome', '_id')] = '' if value.blank? }
    return lancamento_simples
  end

  def prepara_lancamento_simples
    valor_formatado = @valor_do_documento_em_reais.real.quantia.round

    self.valor_total = valor_formatado unless valor_formatado.blank? rescue nil
    self.lancamento_simples = self.limpa_dados_vazios

    dados_primeiro = { :unidade_organizacional => UnidadeOrganizacional.find_by_id(lancamento_simples['unidade_organizacional_id']),
      :centro => Centro.find_by_id(lancamento_simples['centro_id']), :valor => self.valor_total }
    dados_segundo = { :unidade_organizacional => UnidadeOrganizacional.find_by_id(lancamento_simples['unidade_organizacional_id']),
      :centro => Centro.find_by_id(lancamento_simples['centro_id']), :valor => self.valor_total }
    conta_corrente = ContasCorrente.find_by_id(lancamento_simples['conta_corrente_id'])
    dados_primeiro[:plano_de_conta] ||= (conta_corrente ? conta_corrente.conta_contabil : nil)
    dados_segundo[:plano_de_conta] ||= PlanoDeConta.find_by_id(lancamento_simples['conta_contabil_id'])
    
    self.tipo_lancamento == 'E' ? [self, [dados_primeiro], [dados_segundo]] : [self, [dados_segundo], [dados_primeiro]]
  end

  def self.lanca_contabilidade(ano_contabil_atual, lancamento, unidade)
    excecoes = []; valores_debito = 0; valores_credito = 0;
    lancamento.first.is_a?(Movimento) ? movimento = lancamento.first : movimento = Movimento.new(lancamento.first)
    movimento.unidade_id = unidade

    begin
      lancamento[1].each do |dados_debito|
        (dados_debito.has_key?(:plano_de_conta) && dados_debito.has_key?(:unidade_organizacional) &&
            dados_debito.has_key?(:centro)) || raise('Débito com propriedades inválidas')
        dados_debito = Movimento.vincula_novo_centro_e_unidade_organizacional(dados_debito)
        valores_debito += (dados_debito[:valor] || 0)
        dados_debito[:tipo] ||= 'D'
        dados_debito[:movimento] ||= movimento
        dados_debito[:centro] = dados_debito[:centro].pesquisar_correspondente_no_ano_de(ano_contabil_atual) unless dados_debito[:centro].blank?
        dados_debito[:unidade_organizacional] = dados_debito[:unidade_organizacional].pesquisar_correspondente_no_ano_de(ano_contabil_atual) unless dados_debito[:unidade_organizacional].blank?
        movimento.itens_movimentos.build dados_debito
        #p ['DEBITO', dados_debito[:valor]]
      end
    rescue Exception => e
      excecoes << e.message
    end

    begin
      lancamento[2].each do |dados_credito|
        (dados_credito.has_key?(:plano_de_conta) && dados_credito.has_key?(:unidade_organizacional) &&
            dados_credito.has_key?(:centro)) || raise('Crédito com propriedades inválidas')
        dados_credito = Movimento.vincula_novo_centro_e_unidade_organizacional(dados_credito)
        valores_credito += (dados_credito[:valor] || 0)
        dados_credito[:tipo] ||= "C"
        dados_credito[:movimento] ||= movimento
        dados_credito[:centro] = dados_credito[:centro].pesquisar_correspondente_no_ano_de(ano_contabil_atual) unless dados_credito[:unidade_organizacional].blank?
        dados_credito[:unidade_organizacional] = dados_credito[:unidade_organizacional].pesquisar_correspondente_no_ano_de(ano_contabil_atual) unless dados_credito[:unidade_organizacional].blank?
        movimento.itens_movimentos.build dados_credito
        #p ['CREDITO', dados_credito[:valor]]
      end
    rescue Exception => e
      excecoes << e.message
    end

    raise excecoes.join("\n") if excecoes.length > 0

    if valores_debito == valores_credito
      movimento.valor_total = valores_debito if movimento.valor_total.blank?
      begin
        movimento.save!
      rescue Exception => e
        LANCAMENTOS_LOGGER.erro "Erro no lançamento contábil de #{lancamento.inspect}", e
        raise e.message if (movimento.provisao != SIMPLES)
      end
    else
      LANCAMENTOS_LOGGER.erro "Débitos e Créditos não bateram: #{lancamento.inspect}"
      raise 'Débitos e Créditos não bateram'
    end
  end

  def self.vincula_novo_centro_e_unidade_organizacional(dados)
    if dados[:plano_de_conta] && ['11', '21', '51', '61'].include?(dados[:plano_de_conta].codigo_contabil.to_s[0..1]) && dados[:centro] && dados[:unidade_organizacional]
      dados[:centro] = Centro.first(:conditions => ['(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)', '9999999999999999', dados[:plano_de_conta].ano, dados[:plano_de_conta].entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido")
      dados[:unidade_organizacional] = UnidadeOrganizacional.first :conditions => ['(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)', '9999999999', dados[:plano_de_conta].ano, dados[:plano_de_conta].entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válida")
    end
    dados
  end

  def self.procurar_movimentos(busca, unidade_id, contabilizacao_ordem = false)
    busca ||= {}; agrupar_por_provisao = false
    parametro_para_sql = ['movimentos.unidade_id = ?']; conteudo_para_sql = [unidade_id];
    if busca.has_key?('numero_de_controle') || busca.has_key?('ordem')
      return {} if busca['ordem'].blank? && busca['data_inicial'].blank? && busca['data_final'].blank?     
      (parametro_para_sql << 'movimentos.numero_de_controle = ?'; conteudo_para_sql << busca['ordem']) unless busca['ordem'].blank?
      (case busca['tipo']
        when '0';
          parametro_para_sql << '(movimentos.provisao = ? OR movimentos.provisao = ?)';
          conteudo_para_sql << BAIXA
          conteudo_para_sql << SIMPLES
        when '1';
          parametro_para_sql << '(movimentos.provisao = ? AND movimentos.tipo_lancamento <> ?)';
          conteudo_para_sql << PROVISAO
          conteudo_para_sql << 'C'
        when '2';
        else 'Provisão inválida!'
        end) unless busca['tipo'].blank?

      if !busca['data_inicial'].blank? && !busca['data_final'].blank?
        parametro_para_sql << '(movimentos.data_lancamento BETWEEN ? AND ?)'
        conteudo_para_sql << busca['data_inicial'].to_date
        conteudo_para_sql << busca['data_final'].to_date
      elsif !busca['data_inicial'].blank? && busca['data_final'].blank?
        parametro_para_sql << 'movimentos.data_lancamento = ?'; conteudo_para_sql << busca['data_inicial'].to_date
      elsif busca['data_inicial'].blank? && !busca['data_final'].blank?
        parametro_para_sql << 'movimentos.data_lancamento = ?'; conteudo_para_sql << busca['data_final'].to_date
      end
      agrupar_por_provisao = true
    else
      (parametro_para_sql << '(pessoas.nome LIKE ? OR pessoas.razao_social LIKE ?)'; 2.times {conteudo_para_sql << busca['nome_fornecedor'].formatar_para_like}) unless busca['nome_fornecedor'].blank?
      (parametro_para_sql << 'movimentos.numero_de_controle LIKE ?'; conteudo_para_sql << busca['numero_controle'].formatar_para_like) unless busca['numero_controle'].blank?
      (parametro_para_sql << 'movimentos.data_lancamento = ?'; conteudo_para_sql << busca['data_lancamento'].to_date) unless busca['data_lancamento'].blank?
      (parametro_para_sql << 'movimentos.valor_total = ?'; conteudo_para_sql << (format("%.2f", busca['valor']).to_f * 100)) unless busca['valor'].blank?
    end
    movimentos = Movimento.all :include => :pessoa, :conditions => [parametro_para_sql.join(" AND ")] + conteudo_para_sql, :order => 'movimentos.data_lancamento ASC, movimentos.numero_de_controle ASC, movimentos.numero_da_parcela ASC, movimentos.id ASC'
    unless contabilizacao_ordem
      agrupar_por_provisao ? movimentos.group_by(&:provisao) : movimentos.group_by(&:numero_de_controle)
    else
      movimentos
    end
  end

  def remove_itens_do_movimento
    self.itens_movimentos.each { |item| item.destroy }
  end
  
  def before_create
    monta_numero_de_controle_e_salva unless numero_de_controle
  end

  def monta_numero_de_controle_e_salva
    prefixo_do_numero = self.unidade.sigla + "-#{self.tipo_documento}#{DateTime.now.strftime("%m/%y")}"
    self.numero_de_controle = Gefin.monta_numeros_de_controle(prefixo_do_numero)
  end

  def data_de_lancamento_valida?
    p "oi"
    return false if data_lancamento.blank? || unidade.blank?
    p "oi2"
   
    p data_lancamento.to_date
    p (Date.today - unidade.lancamentosmovimentofinanceiro)
    p  (data_lancamento.to_date) >= (Date.today - unidade.lancamentosmovimentofinanceiro)

    if (data_lancamento.to_date) >= (Date.today - unidade.lancamentosmovimentofinanceiro)
      true
    else
      false
    end
    #(data_lancamento_was || data_lancamento).to_date.between?((Date.today - unidade.lancamentosmovimentofinanceiro).to_date, (Date.today + unidade.lancamentosmovimentofinanceiro).to_date)
  end

  def validar_data_inicio_entre_limites
    return true if self.data_lancamento.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_minima.blank?
      if self.data_lancamento.to_date.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def self.descreve_tipo_do_lancamento(valor)
    case valor
    when BAIXA; 'Baixados'
    when PROVISAO; 'Provisionados'
    when SIMPLES; 'Simples'
    end
  end

  def lancamento_simples
    unless @lancamento_simples
      @lancamento_simples = {}
      # Carrega o primeiro movimento, lembre-se que os atributos cento e unidade organizacional são identicos para o débito e o crédito
      primeiro_item_movimento = self.itens_movimentos.first
      # Atribui o centro
      centro = Centro.find(primeiro_item_movimento.centro_id)
      @lancamento_simples['centro_nome'] ||= centro.codigo_centro + ' - ' + centro.nome
      @lancamento_simples['centro_id'] ||= primeiro_item_movimento.centro_id
      # Atribui unidade organizacional
      unidade_organizacional = UnidadeOrganizacional.find(primeiro_item_movimento.unidade_organizacional_id)
      @lancamento_simples['unidade_organizacional_nome'] ||= unidade_organizacional.codigo_da_unidade_organizacional + ' - ' + unidade_organizacional.nome
      @lancamento_simples['unidade_organizacional_id'] ||= primeiro_item_movimento.unidade_organizacional_id
      # Atribui plano de conta e conta corrente
      self.itens_movimentos.each do |item_movimento|
        if ((self.tipo_lancamento == 'E' && item_movimento.tipo == 'D') || (self.tipo_lancamento == 'S' && item_movimento.tipo == "C"))
          conta_corrente = ContasCorrente.find_by_conta_contabil_id(item_movimento.plano_de_conta_id)
          @lancamento_simples['conta_corrente_nome'] ||= conta_corrente.resumo_conta_corrente
          @lancamento_simples['conta_corrente_id'] ||= conta_corrente.id
        else
          conta_contabil = PlanoDeConta.find(item_movimento.plano_de_conta_id)
          @lancamento_simples['conta_contabil_nome'] ||= conta_contabil.codigo_contabil + ' - ' + conta_contabil.nome
          @lancamento_simples['conta_contabil_id'] ||= conta_contabil.id
        end
      end
    end
    @lancamento_simples
  end

  def faz_update_de_movimento(ano, parametros, unidade)
    begin      
      lancamento = parametros.delete('lancamento_simples')
      itens_movimentos_antigos = self.itens_movimentos.collect(&:id)
      Movimento.transaction do
        update_attributes(parametros) || raise('Não conseguiu executar a atualização de movimento')
        self.lancamento_simples = lancamento
        Movimento.lanca_contabilidade(ano, prepara_lancamento_simples, unidade) || raise('Erro ao lançar a contabilidade')
        itens_movimentos_antigos.each {|identificador| ItensMovimento.find(identificador).destroy}
        true
      end
    rescue Exception => e
      false
    end
  end

  def before_destroy
		if self.provisao == Movimento::SIMPLES && !self.destruindo
			if !data_de_lancamento_valida? && !validar_data_inicio_entre_limites
				errors.add :data_lancamento, 'excedeu o limite máximo permitido'
				false
			else
				true
			end
  	end
  end
  
  def self.procurar_movimentos_para_estorno(numero_controle)
    retorno = []
    retorno << Movimento.first(:conditions => ['provisao = ? AND numero_de_controle = ?', SIMPLES, numero_controle])
    retorno << PagamentoDeConta.first(:conditions => ['numero_de_controle = ?', numero_controle])
    retorno << RecebimentoDeConta.first(:conditions => ['numero_de_controle = ?', numero_controle])
    retorno = retorno.compact
    if retorno.blank?
      retorno
    else
      retorno.first.movimentos
    end
  end
  
  def self.gravar_lancamento_de_estorno(current_user, movimento_id, unidade, data, justificativa, historico)
    return [false, 'Você deve selecionar um movimento para efetuar a operação'] if movimento_id.blank?
    return [false, 'O campo Data do Estorno deve ser preenchido'] if data.blank?
    return [false, 'O campo Justificativa deve ser preenchido'] if justificativa.blank?
    begin
      Movimento.transaction do
        configuracao = Unidade.find_by_id(unidade)
        limite = configuracao.limitediasparaestornodeparcelas
        data_permitida = (data.to_date >= (Date.today - limite)) ? true : false

        
        if data_permitida
          movimento = Movimento.find_by_id(movimento_id)

          ##### VALIDAÇÃO PARA VERIFICAR SE JÁ NÃO FOI LANÇADO UM MOVIMENTO DE ESTORNO
				  parcela = movimento.parcela
					movimentos = Movimento.find_all_by_parcela_id_and_tipo_lancamento(parcela.id,'U')
					if movimentos.length > 0
						return [false, 'Já foi realizado um movimento de estorno para este movimento']
					end
          #####

          novo_mov = movimento.clone
          novo_mov.historico = historico.blank? ? (movimento.conta.historico + ' (Estorno Manual)') : (historico)
          novo_mov.tipo_lancamento = 'U'
          novo_mov.tipo_documento = movimento.conta.tipo_de_documento
          novo_mov.data_lancamento = data.to_date
          novo_mov.provisao = Movimento::PROVISAO
          novo_mov.pessoa_id = movimento.conta.pessoa_id
          novo_mov.numero_da_parcela = movimento.parcela.numero if !movimento.parcela.numero.blank?
          novo_mov.unidade_id = unidade
          
          movimento.itens_movimentos.each do |item|
            novo_mov.itens_movimentos << item.clone
          end
          novo_mov.save!
          novo_mov.itens_movimentos.each do |it|
            if it.tipo == 'C'
              it.tipo = 'D'
            else
              it.tipo = 'C'
            end
            it.save!
          end

          HistoricoOperacao.cria_follow_up(novo_mov.historico, current_user, movimento.parcela.conta, justificativa, nil, nil)
          return [true, 'Operação efetuada com sucesso']
        else
          return [false, 'A data da operação está fora dos limites estabelecidos']
        end
      end
    rescue Exception => e
      [false, e.message]
    end
  end
  
end
