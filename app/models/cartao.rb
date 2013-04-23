class Cartao < ActiveRecord::Base
  extend BuscaExtendida

  acts_as_audited

  #SITUACAO
  GERADO = 1
  BAIXADO = 2
  TROCADO = 3

  #CARTÕES
  VISACREDITO = 1
  REDECARD = 2
  MASTERCARD = 3
  DINERS = 4
  AMERICANEXPRESS = 5
  MAESTRO = 6
  CREDICARD = 7
  OUROCARD = 8
  VISADEBITO = 9

  #RELACIONAMENTOS  
  belongs_to :parcela
  belongs_to :parcela_recebimento_de_conta, :class_name => 'ParcelaRecebimentoDeConta', :foreign_key => 'parcela_id'
  belongs_to :conta_contabil, :class_name => 'PlanoDeConta', :foreign_key => 'plano_de_conta_id'
  
  #CAMPOS OBRIGATÓRIOS
  validates_presence_of :data_do_deposito, :historico, :conta_contabil, :message => 'deve ser preenchido.', :if => Proc.new {|c| c.situacao == BAIXADO}
  validates_presence_of :parcela, :message => 'deve ser preenchido.'
  validates_presence_of :numero, :validade, :nome_do_titular, :message => 'deve ser preenchido.'
  #validates_presence_of :codigo_de_seguranca, :message => 'deve ser preenchido.'
  validates_inclusion_of :bandeira, :in => [AMERICANEXPRESS, VISACREDITO, REDECARD, MASTERCARD, MAESTRO, CREDICARD, VISADEBITO], :message => 'deve ser preenchido.'
  attr_protected :plano_de_conta_id, :data_do_deposito

  #DATAS
  data_br_field :data_do_deposito
  converte_para_data_para_formato_date :data_do_deposito
    
  HUMANIZED_ATTRIBUTES = {
    :parcela => 'O campo parcela',
    :bandeira => 'O campo bandeira',
    :numero => 'O campo numero',
    :codigo_de_seguranca => 'O campo codigo de seguranca',
    :validade => 'O campo validade',
    :nome_do_titular => 'O campo nome do titular',
    :data_do_deposito => 'O campo data do depósito',
    :conta_contabil => 'O campo conta',
    :historico => 'O campo histórico'
  }

  def validate
    errors.add :validade, 'Mês inválido ou formato inválido, a validade deve estar no padrão MM/AAAA.' unless mes_valido?
    #errors.add :base, 'O cartão já foi baixado.' if situacao_was == BAIXADO && !self.parcela.pode_estornar_parcela? && !self.parcela.estornando
    errors.add :data_do_deposito, "não pode ser maior do que a data de hoje - #{Date.today.to_s_br}" if self.data_do_deposito && self.data_do_deposito.to_date > Date.today
  end

  #PARA BAIXA
  def data_limite_valida_de_operacao?(data)
    return true if data.blank? || unidade.blank?
    if (data) >= (Date.today - unidade.lancamentoscartoes)
      true
    else
      false
    end
  end
  
  def data_valida_para_estorno?(data)
    return true if data.blank? || unidade.blank?
    if (data) >= (Date.today - unidade.limitediasparaestornodeparcelas)
      true
    else
      false
    end
  end

  def validar_data_de_operacao_entre_periodo(data)
    return true if data.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if data.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def initialize(attributes = {})
    super attributes
    self.situacao = GERADO
  end

  def bandeira_verbose
    case bandeira
    when VISACREDITO; "Visa Crédito"
    when REDECARD; "Redecard"
    when MASTERCARD; "Mastercard"
    when DINERS; "Diners"
    when AMERICANEXPRESS; "American Express"
    when MAESTRO; "Maestro"
    when CREDICARD; "Credicard"
    when OUROCARD; "Ourocard"
    when VISADEBITO; "Visa Débito"
    end
  end

  def situacao_verbose
    case situacao
    when GERADO; 'Pendente'
    when BAIXADO; 'Baixado'
    end
  end

  def valor_liquido
    format("%.2f", self.parcela.valor / 100.0)
  end
  
  def self.retorna_bandeiras_para_select
    [['', ''], ['American Express', AMERICANEXPRESS], ['Maestro', MAESTRO], ['Mastercard', MASTERCARD],
      ['Redecard', REDECARD], ['Visa Crédito', VISACREDITO], ['Visa Débito', VISADEBITO]]
  end

  def mes_valido?
    return false unless validade
    return false unless validade.match %r{^(..)(.).*$}
    true if ($1.to_i >= 1) && ($1.to_i <= 12) && ($2 == '/')
  end  
  
  def validate_on_create
    unless validade.blank?
      validade.match %r{^(..).(.*).*$} 
      ano = $2.to_i
      mes = $1.to_i
      ano_corrente = Date.today.strftime("%y").to_i
      mes_corrente = Date.today.strftime("%m").to_i
      errors.add :validade, 'está com a validade vencida.' if (ano < ano_corrente) || (ano <= ano_corrente && mes < mes_corrente)
    end
  end

  def self.pesquisar_cartoes(parametros, unidade)
    return [] if parametros.blank?
    @sqls = ['recebimento_de_contas.unidade_id = ?']; @variaveis = [unidade]

    preencher_array_para_buscar_por_faixa_de_datas parametros, 'data_de_recebimento', 'parcelas.data_da_baixa'
    (@sqls << 'cartoes.bandeira = ?'; @variaveis << parametros['bandeira'].to_i) unless parametros['bandeira'].blank?

    unless parametros['situacao'].blank?
      @sqls << 'cartoes.situacao = ?'
      case parametros['situacao']
      when '1'; @variaveis << GERADO
      when '2';
        @variaveis << BAIXADO
        preencher_array_para_buscar_por_faixa_de_datas parametros, 'data_do_deposito', 'cartoes.data_do_deposito'
      end
    end

    unless parametros['texto'].blank?
      @sqls << '(cartoes.nome_do_titular LIKE ? OR pessoas.nome LIKE ?)'
      2.times { @variaveis << parametros['texto'].formatar_para_like }
    end

    Cartao.find(:all, :include => [:parcela_recebimento_de_conta => {:conta => :pessoa}],
      :conditions => ([@sqls.join(' AND ')] + @variaveis), :order => 'data_de_recebimento DESC, pessoas.nome ASC, pessoas.razao_social ASC')
  end

  def self.baixar(ano, parametros, identificador_da_unidade)
    parametros ||= {}
    begin
      Cartao.transaction do
        unless parametros['ids'].blank?
          parametros['ids'].each do |i|
            unidade = Unidade.find identificador_da_unidade rescue raise 'Unidade inválida!'
            cartao = Cartao.find i, :include => [:parcela_recebimento_de_conta => :conta],
              :conditions => ['(cartoes.situacao = ? AND recebimento_de_contas.unidade_id = ?)', GERADO, unidade.id] rescue raise("Você selecionou dados que já foram baixados!")

            if cartao.data_limite_valida_de_operacao?(parametros['data_do_deposito'].to_date) || cartao.validar_data_de_operacao_entre_periodo(parametros['data_do_deposito'].to_date)
              plano_de_conta = PlanoDeConta.find_by_id_and_entidade_id(parametros['conta_contabil_id'], unidade.entidade_id) || raise('Selecione uma conta válida!')
              cartao.conta_contabil = plano_de_conta
              cartao.situacao = BAIXADO
              cartao.data_do_deposito = parametros['data_do_deposito']
              cartao.historico = parametros['historico']
              if cartao.save
                cartao.efetua_lancamento_contabil_de_cartao(ano) || raise('Não foi possível gerar um lançamento financeiro!')
              else
                raise("Não foi possível baixar os dados!\n* #{cartao.errors.full_messages.join("\n")}")
              end
            else
              raise('A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.')
            end
          end
        else
          raise 'Selecione pelo menos um dado para executar a baixa!'
        end
        [true, 'Dados baixados com sucesso!']
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def self.estornar(parametros, identificador_da_unidade, data_estorno, justificativa)
    parametros ||= {}
    return [false, 'O campo Data do Estorno é de preenchimento obrigatório'] if data_estorno.blank?
    return [false, 'O campo Justificativa é de preenchimento obrigatório'] if justificativa.blank?
    return [false, 'A Data do Estorno não pode ser maior que a data de hoje'] if data_estorno.to_date > Date.today
    begin
      Cartao.transaction do
        unless parametros['ids'].blank?
          parametros['ids'].each do |i|
            unidade = Unidade.find identificador_da_unidade rescue raise 'Unidade inválida!'
            cartao = Cartao.find i, :include => [:parcela_recebimento_de_conta => :conta],
              :conditions => ['(cartoes.situacao = ? AND recebimento_de_contas.unidade_id = ?)', BAIXADO, unidade.id] rescue raise("Você selecionou cartões não baixados!")

            if cartao.data_valida_para_estorno?(data_estorno.to_date) || cartao.validar_data_de_operacao_entre_periodo(data_estorno.to_date)
              parcela = cartao.parcela
              parcela.estornando = true

              movimento = parcela.movimentos.select do |obj|
                obj.provisao == Movimento::BAIXA && parcela.id == obj.parcela_id && obj.tipo_lancamento == 'R' # --> BAIXA DO CHEQUE
                #obj.provisao == Movimento::BAIXA && parcela.id == obj.parcela_id && obj.tipo_lancamento == 'S' --> BAIXA DA PARCELA
              end.last

              novo_mov = movimento.clone
              novo_mov.historico = parcela.historico + ' (Estorno de Cartão)'
              novo_mov.tipo_lancamento = 'I'
              novo_mov.tipo_documento = parcela.conta.tipo_de_documento
              novo_mov.data_lancamento = data_estorno.to_date
              novo_mov.provisao = Movimento::PROVISAO
              novo_mov.pessoa_id = parcela.conta.pessoa_id
              novo_mov.numero_da_parcela = parcela.numero
              movimento.itens_movimentos.each do |item|
                novo_mov.itens_movimentos << item.clone
              end
              novo_mov.save!
              novo_mov.itens_movimentos.each do |it|
                it.tipo = it.tipo == 'C' ? 'D' : 'C'
                it.save!
              end
              #parcela.remove_movimento_e_itens_com_tipo_de_movimento(Movimento::BAIXA, 'R')
              cartao.data_do_deposito = nil
              cartao.situacao = GERADO
              cartao.save!
              parcela.estornando = false
            else
              raise('A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.')
            end
          end
        else
          raise 'Selecione pelo menos um cartão para estornar!'
        end
        [true, 'Cartões estornados com sucesso!']
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def efetua_lancamento_contabil_de_cartao(ano)
    hash_contabil ||= {}; debitos = []; creditos = []; soma = 0
    #DÉBITOS --- Conta contábil escolhida na view
    self.parcela.insere_no_hash(hash_contabil, 'debito', {:unidade_organizacional => self.parcela.conta.unidade_organizacional,
        :plano_de_conta => self.conta_contabil, :centro => self.parcela.conta.centro, :valor => self.parcela.valor_liquido})
    #FIM DÉBITOS

    #CRÉDITOS
    unless self.parcela.conta.unidade.blank?
      raise "Deve ser parametrizada uma conta contábil para o Cartão escolhido - #{self.bandeira_verbose}." if self.parcela.conta.unidade.parametro_conta_valor_cartoes(ano, self.bandeira).blank?
    end
    self.parcela.insere_no_hash(hash_contabil, 'credito', {:centro => self.parcela.conta.centro,
        :unidade_organizacional => self.parcela.conta.unidade_organizacional,
        :plano_de_conta => self.parcela.conta.unidade.parametro_conta_valor_cartoes(ano, self.bandeira).conta_contabil,
        :valor => self.parcela.valor_liquido})
    #FIM CRÉDITOS

    hash_contabil['debito'].each_value {|conteudo| debitos << conteudo}
    hash_contabil['credito'].each_value {|conteudo| creditos << conteudo}

    Movimento.lanca_contabilidade(ano, [{:conta => self.parcela.conta, :historico => self.historico,
          :numero_de_controle => self.parcela.conta.numero_de_controle,
          :data_lancamento => self.data_do_deposito, :tipo_lancamento => 'R',
          :tipo_documento => self.parcela.conta.tipo_de_documento, :provisao => Movimento::BAIXA,
          :pessoa => self.parcela.conta.pessoa, :numero_da_parcela => self.parcela.numero,
          :parcela => self.parcela}, debitos, creditos], self.parcela.conta.unidade_id)
  end

  def unidade
    self.parcela.unidade
  end

end
