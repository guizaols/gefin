class Cheque < ActiveRecord::Base
  extend BuscaExtendida

  acts_as_audited

  #CONSTANTES
  GERADO = 1
  BAIXADO = 2
  DEVOLVIDO = 3
  ABANDONADO = 4
  REAPRESENTADO = 5
  TROCADO = 6

  #CONSTANTES UTILIZADAS PARA MINHA VIEW DE CHEQUES
  ENVIO_DR = 1
  RENEGOCIACAO = 2
  DEVOLUCAO = 3

  VISTA = 1
  PRAZO = 2

  #RELACIONAMENTOS
  belongs_to :parcela
  belongs_to :parcela_recebimento_de_conta, :class_name => 'ParcelaRecebimentoDeConta', :foreign_key => 'parcela_id'
  belongs_to :banco
  belongs_to :conta_contabil, :class_name => 'PlanoDeConta', :foreign_key => 'plano_de_conta_id'
  belongs_to :conta_contabil_transitoria, :class_name => 'PlanoDeConta', :foreign_key => 'conta_contabil_transitoria_id'
  belongs_to :conta_contabil_devolucao, :class_name => 'PlanoDeConta', :foreign_key => 'conta_contabil_devolucao_id'
  has_many :ocorrencia_cheques

  #CAMPOS OBRIGATÓRIOS
  validates_presence_of :parcela , :message => 'deve ser preenchido.'
  validates_presence_of :conta_contabil_transitoria, :message => "deve ser preenchido.", :if=>Proc.new{|c| c.situacao == GERADO}
  validates_presence_of :banco, :message => 'deve ser preenchido.'
  validates_presence_of :agencia, :conta, :numero, :data_para_deposito, :nome_do_titular, :message => 'deve ser preenchido.'
  validates_presence_of :data_do_deposito, :conta_contabil, :message => "deve ser preenchido.", :if => Proc.new {|c| c.situacao == BAIXADO}
  validates_inclusion_of :prazo, :in => [VISTA, PRAZO], :message => 'deve ser preenchido.'
  attr_protected :plano_de_conta_id, :data_do_deposito
  attr_accessor :nome_banco,:conta_contabil_transitoria_nome
  attr_accessor :raise_exception
  cria_atributos_virtuais_para_auto_complete :conta_contabil_transitoria
  cria_readers_e_writers_para_o_nome_dos_atributos :conta_contabil_devolucao

  #DATAS
  data_br_field :data_do_deposito, :data_de_recebimento, :data_para_deposito, :data_devolucao, :data_abandono
  converte_para_data_para_formato_date :data_de_recebimento, :data_para_deposito, :data_do_deposito, :data_devolucao, :data_abandono

  #FILTROS DE BUSCA
  named_scope :a_vista, :conditions => ['data_de_recebimento = data_para_deposito']
  named_scope :a_prazo, :conditions => ['data_de_recebimento <> data_para_deposito']

  def initialize(attributes = {})
    super attributes
    self.situacao = GERADO
  end

  def nome_banco
    self.banco.nome if self.banco
  end

  def prazo_verbose
    case prazo
    when VISTA; 'À Vista'
    when PRAZO; 'Prazo'
    end
  end

  HUMANIZED_ATTRIBUTES = {
    :parcela => 'O campo parcela',
    :banco =>'O campo banco',
    :agencia =>'O campo agência',
    :conta => 'O campo conta',
    :numero => 'O campo número',
    :data_de_recebimento => 'O campo data de recebimento',
    :data_devolucao => 'O campo data da devolução',
    :data_abandono => 'O campo data do abandono',
    :data_para_deposito => 'O campo data para depósito',
    :data_do_deposito => 'O campo data do depósito',
    :nome_do_titular => 'O campo nome do titular',
    :conta_contabil => 'O campo conta',
  }

  def situacao_verbose
    case situacao
    when GERADO; 'Pendente'
    when BAIXADO; 'Baixado'
    when DEVOLVIDO; 'Devolvido'
    when ABANDONADO; 'Abandonado'
    when REAPRESENTADO; 'Reapresentado'
    end
  end

  def self.retorna_bancos_para_select
    Banco.all.collect {|banco| [ banco.descricao, banco.id ] }
  end

  def validate
    errors.add :base, 'O cheque já foi baixado.' if situacao_was == BAIXADO && situacao != DEVOLVIDO && !self.parcela.pode_estornar_parcela? && !self.parcela.estornando
    errors.add :data_do_deposito, "não pode ser maior do que a data de hoje - #{Date.today.to_s_br}" if self.data_do_deposito && self.data_do_deposito.to_date > Date.today
    errors.add :data_abandono, "não pode ser maior do que a data de hoje - #{Date.today.to_s_br}" if self.data_abandono && self.data_abandono.to_date > Date.today
    errors.add :data_devolucao, "não pode ser maior do que a data de hoje - #{Date.today.to_s_br}" if self.data_devolucao && self.data_devolucao.to_date > Date.today
  end

  # PARA BAIXA, DEVOLUÇÃO OU ABANDONO
  def data_limite_valida_de_operacao?(data)
    return true if data.blank? || unidade.blank?
    if (data) >= (Date.today - unidade.lancamentoscheques)
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

  def pre_datado?
    self.prazo == PRAZO
  end

  def self.pesquisar_cheques(parametros, unidade)
    return [] if parametros.blank?
    @sqls = ['recebimento_de_contas.unidade_id = ?']
    @variaveis = [unidade]
    unless parametros['vista'].blank?
      @sqls << "cheques.prazo = ?"
      @variaveis << [VISTA]
    end
    unless parametros['pre_datado'].blank?
      @sqls << "cheques.prazo = ?"
      @variaveis << [PRAZO]
    end
    unless parametros['situacao'].blank?
      @sqls << '(cheques.situacao IN (?))'
      case parametros['situacao']
      when '1'; @variaveis << [GERADO]
      when '2';
        @variaveis << [BAIXADO, REAPRESENTADO]
        preencher_array_para_buscar_por_faixa_de_datas parametros, 'data_do_deposito', 'cheques.data_do_deposito'
      when '3'; @variaveis << [DEVOLVIDO]
      end
    end
    unless parametros['texto'].blank?
      @sqls << '(cheques.nome_do_titular LIKE ? OR pessoas.nome LIKE ? OR cheques.numero LIKE ?)'
      3.times { @variaveis << parametros['texto'].formatar_para_like }
    end
    Cheque.all(:include => [:parcela_recebimento_de_conta => {:conta => :pessoa}], :conditions => ([@sqls.join(' AND ')] + @variaveis), :order => 'cheques.data_de_recebimento ASC')
  end

  def self.baixar(ano, parametros, identificador_da_unidade, usuario_corrente)
    parametros ||= {}
    begin
      exceptions = []
      Cheque.transaction do
        exceptions << "* Selecione uma conta contábil válida" if parametros["conta_contabil_id"].blank?
        exceptions << "* O campo histórico deve ser preenchido" if parametros["historico"].blank?
        exceptions << "* O campo data do depósito deve ser preenchido" if parametros["data_do_deposito"].blank?
        exceptions << "* Selecione pelo menos um cheque para executar a baixa" if parametros["ids"].blank?
        raise exceptions.join("\n") unless exceptions.blank?
        parametros['ids'].each do |i|
          unidade = Unidade.find identificador_da_unidade rescue raise 'Unidade inválida!'
          cheque = Cheque.find i, :include => [:parcela_recebimento_de_conta => :conta],
            :conditions => ["(recebimento_de_contas.unidade_id = ?)", unidade.id] rescue raise("Você não pode baixar os cheques selecionados!")
          plano_de_conta = PlanoDeConta.find_by_id_and_entidade_id(parametros['conta_contabil_id'], unidade.entidade_id) || raise('Selecione uma conta válida!')

          if cheque.data_limite_valida_de_operacao?(parametros['data_do_deposito'].to_date) || cheque.validar_data_de_operacao_entre_periodo(parametros['data_do_deposito'].to_date)
            if cheque.situacao == GERADO
              cheque.conta_contabil = plano_de_conta
              cheque.data_do_deposito = parametros['data_do_deposito']
              cheque.historico = parametros['historico']
              cheque.situacao = BAIXADO
              cheque.save || raise("Não foi possível baixar o cheque #{cheque.numero}!\n* #{cheque.errors.full_messages.join("\n")}")
              conta_contabil = !cheque.pre_datado? ? ContasCorrente.find_by_unidade_id_and_identificador(cheque.parcela.conta.unidade_id, ContasCorrente::CAIXA).conta_contabil :
                cheque.conta_contabil_transitoria

              unless parametros.has_key?("estornar")
                Movimento.lanca_contabilidade(ano, [{:conta => cheque.parcela.conta, :historico => parametros["historico"],
                      :numero_de_controle => cheque.parcela.conta.numero_de_controle,
                      :data_lancamento => parametros["data_do_deposito"], :tipo_lancamento => "E",
                      :tipo_documento => cheque.parcela.conta.tipo_de_documento, :provisao => 0,
                      :pessoa => cheque.parcela.conta.pessoa, :numero_da_parcela => cheque.parcela.numero,
                      :parcela => cheque.parcela, :cheque => true, :situacao_cheque => cheque.situacao},
                    [{:plano_de_conta => PlanoDeConta.find_by_id(parametros["conta_contabil_id"]),
                        :centro => cheque.parcela.conta.centro, :valor => cheque.parcela.valor_liquido,
                        :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}],
                    [{:plano_de_conta => conta_contabil, :centro => cheque.parcela.conta.centro,
                        :valor => cheque.parcela.valor_liquido,
                        :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}]],
                  unidade.id)
                
                HistoricoOperacao.cria_follow_up("O cheque #{cheque.numero} foi baixado", usuario_corrente, cheque.parcela.conta, nil, nil, cheque.parcela.valor_liquido)
              end
              
            elsif cheque.situacao == DEVOLVIDO
              cheque.conta_contabil = plano_de_conta
              cheque.data_do_deposito = parametros['data_do_deposito']
              cheque.historico = parametros['historico']
              cheque.situacao = REAPRESENTADO
              cheque.save || raise("Não foi possível reapresentar o cheque #{cheque.numero}!\n* #{cheque.errors.full_messages.join("\n")}")

              unless parametros.has_key?("estornar")
                Movimento.lanca_contabilidade(ano, [
                    {:conta => cheque.parcela.conta, :historico => parametros["historico"],
                      :numero_de_controle => cheque.parcela.conta.numero_de_controle, :data_lancamento => parametros["data_do_deposito"],
                      :tipo_lancamento => "E", :tipo_documento => cheque.parcela.conta.tipo_de_documento,
                      :provisao => 0, :pessoa => cheque.parcela.conta.pessoa, :numero_da_parcela => cheque.parcela.numero,
                      :parcela => cheque.parcela, :cheque => true, :situacao_cheque => cheque.situacao},
                    [{:plano_de_conta => PlanoDeConta.find_by_id(parametros["conta_contabil_id"]),
                        :centro => cheque.parcela.conta.centro, :valor => cheque.parcela.valor_liquido,
                        :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}],
                    [{:plano_de_conta => PlanoDeConta.find_by_id(cheque.conta_contabil_devolucao),
                        :centro => cheque.parcela.conta.centro, :valor => cheque.parcela.valor_liquido,
                        :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}]],
                  unidade.id)

                ocorrencia = OcorrenciaCheque.new(:cheque => cheque, :data_do_evento => parametros["data_do_deposito"].to_date,
                  :tipo_da_ocorrencia => DEVOLUCAO, :historico => parametros['historico'])
                ocorrencia.save!
                
                HistoricoOperacao.cria_follow_up("O cheque #{cheque.numero} foi reapresentado", usuario_corrente, cheque.parcela.conta, nil, nil, cheque.parcela.valor_liquido)
              end
            else
              raise("O cheque selecionado não pode ser devolvido!")
            end
          else
            raise("A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.")
          end
        end
        [true, 'Cheque baixado com sucesso!']
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def self.estornar(ano, parametros, identificador_da_unidade, data_estorno, justificativa, usuario)
    parametros ||= {}    
    return [false, 'O campo Data do Estorno é de preenchimento obrigatório'] if data_estorno.blank?
    return [false, 'O campo Justificativa é de preenchimento obrigatório'] if justificativa.blank?
    return [false, 'A Data do Estorno não pode ser maior que a data de hoje'] if data_estorno.to_date > Date.today
    begin
      Cheque.transaction do
        unless parametros["ids"].blank?
          parametros['ids'].each do |i|
            unidade = Unidade.find identificador_da_unidade rescue raise 'Unidade inválida!'
            cheque = Cheque.find i, :include => [:parcela_recebimento_de_conta => :conta],
              :conditions => ["(recebimento_de_contas.unidade_id = ?)", unidade.id] rescue raise("Você não pode baixar os cheques selecionados!")

            #if cheque.data_limite_valida_de_operacao?(Date.today) || cheque.validar_data_de_operacao_entre_periodo(Date.today)
            if cheque.situacao == BAIXADO #BAIXADO para PENDENTE
              if cheque.data_valida_para_estorno?(data_estorno.to_date) || cheque.validar_data_de_operacao_entre_periodo(data_estorno.to_date)  
                return [false, '* A Data do Estorno não pode ser maior que a data de hoje'] if data_estorno.to_date > Date.today
                parcela = cheque.parcela
                parcela.estornando = true

                movimento = parcela.movimentos.select do |obj|
                  obj.provisao == Movimento::BAIXA && parcela.id == obj.parcela_id && obj.cheque && obj.situacao_cheque == Cheque::BAIXADO
                end.last
                novo_mov = movimento.clone
                novo_mov.historico = parcela.historico + ' (Estorno de Baixa de Cheque)'
                novo_mov.tipo_lancamento = 'F'
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
                #parcela.remove_movimento_e_itens(Movimento::BAIXA, true, Cheque::BAIXADO)
                cheque.situacao = GERADO
                cheque.save!
                parcela.estornando = false
                HistoricoOperacao.cria_follow_up("Cheque #{cheque.numero} teve sua situação estornada de Baixado para Pendente", usuario, cheque.parcela.conta, justificativa, nil, cheque.parcela.valor_liquido)
              else
                return [false, 'A operação não pode ser efetuada pois o limite de dias retroativos foi excedido']
              end
            elsif cheque.situacao == DEVOLVIDO #DEVOLVIDO para BAIXADO
              parcela = cheque.parcela
              parcela.estornando = true
              
              movimento = parcela.movimentos.select do |obj|
                obj.provisao == Movimento::BAIXA && parcela.id == obj.parcela_id && obj.cheque && obj.situacao_cheque == Cheque::DEVOLVIDO
              end.last
              novo_mov = movimento.clone
              novo_mov.historico = parcela.historico + ' (Estorno de Devolução de Cheque)'
              novo_mov.tipo_lancamento = 'L'
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
              #parcela.remove_movimento_e_itens(Movimento::BAIXA, true, Cheque::DEVOLVIDO)
              cheque.situacao = GERADO
              cheque.save!
              parametros["historico"] = "VLR REF. #{cheque.parcela.conta.nome_pessoa} PARC. #{cheque.parcela.numero} CH. NUM. #{cheque.numero}"
              parametros["conta_contabil_id"] = cheque.conta_contabil.id
              parametros["estornar"] = true
              Cheque.baixar(ano, parametros, identificador_da_unidade, usuario)
              parcela.estornando = false
              ocorrencias = OcorrenciaCheque.find(:all, :conditions => ['cheque_id = ? AND tipo_da_ocorrencia IN (?)', cheque.id, [ENVIO_DR, RENEGOCIACAO]])
              ocorrencias.each{|ocorrencia| ocorrencia.destroy} unless ocorrencias.blank?
              HistoricoOperacao.cria_follow_up("Cheque #{cheque.numero} teve sua situação estornada de Devolvido para Baixado", usuario, cheque.parcela.conta, justificativa, nil, cheque.parcela.valor_liquido)

            elsif cheque.situacao == REAPRESENTADO #REAPRESENTADO para DEVOLVIDO
              parcela = cheque.parcela
              parcela.estornando = true
              
              movimento = parcela.movimentos.select do |obj|
                obj.provisao == Movimento::BAIXA && parcela.id == obj.parcela_id && obj.cheque && obj.situacao_cheque == Cheque::REAPRESENTADO
              end.last
              novo_mov = movimento.clone
              novo_mov.historico = parcela.historico + ' (Estorno de Reapresentação de Cheque)'
              novo_mov.tipo_lancamento = 'M'
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
              #parcela.remove_movimento_e_itens(Movimento::BAIXA, true, Cheque::REAPRESENTADO)
              cheque.save!
              parametros["historico"] = "VLR REF.  #{cheque.parcela.conta.nome_pessoa} PARC. #{cheque.parcela.numero} CH. NUM. #{cheque.numero}"
              parametros["conta_contabil_devolucao_id"] = cheque.conta_contabil_devolucao_id
              parametros["estornar"] = true
              Cheque.devolver(ano, parametros, identificador_da_unidade, usuario)
              ocorrencias = OcorrenciaCheque.find(:all, :conditions => ['cheque_id = ? AND tipo_da_ocorrencia = ?', cheque.id, DEVOLUCAO])
              ocorrencias.each{|ocorrencia| ocorrencia.destroy} unless ocorrencias.blank?
              parcela.estornando = false
              HistoricoOperacao.cria_follow_up("Cheque #{cheque.numero} teve sua situação estornada de Reapresentado para Devolvido", usuario, cheque.parcela.conta, justificativa, nil, cheque.parcela.valor_liquido)
            end
            #else
            #raise("A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.")
            #end
          end
        else
          raise("Selecione pelo menos um cheque para estornar!")
        end
        [true, "Cheque estornado com sucesso!"]
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def valor_liquido
    format("%.2f", self.parcela.valor / 100.0)
  end

  def self.abandonar(ano, parametros, identificador_da_unidade, usuario_corrente)
    begin
      exceptions = []
      Cheque.transaction do
        exceptions << "* Selecione uma Conta Contábil Débito válida" if parametros["conta_contabil_debito_id"].blank?
        exceptions << "* Selecione uma Conta Contábil Crédito válida" if parametros["conta_contabil_credito_id"].blank?
        exceptions << "* O campo histórico deve ser preenchido" if parametros["historico"].blank?
        exceptions << "* O campo data do abandono deve ser preenchido" if parametros["data_abandono"].blank?
        exceptions << "* Selecione pelo menos um cheque para executar o abandono" if parametros["ids"].blank?
        raise exceptions.join("\n") unless exceptions.blank?
        parametros['ids'].each do |id|
          unidade = Unidade.find identificador_da_unidade rescue raise 'Unidade inválida!'
          cheque = Cheque.find id, :include => [:parcela_recebimento_de_conta => :conta],:conditions => ["(cheques.situacao = ? AND recebimento_de_contas.unidade_id = ?)", DEVOLVIDO, unidade.id] rescue raise("Você selecionou cheques que já foram baixados!")

          if cheque.data_limite_valida_de_operacao?(parametros['data_abandono'].to_date) || cheque.validar_data_de_operacao_entre_periodo(parametros['data_abandono'].to_date)
            cheque.historico = parametros['historico']
            cheque.data_do_deposito = nil
            cheque.data_abandono = parametros['data_abandono']
            cheque.situacao = ABANDONADO
            cheque.save || raise("Não foi possível baixar o cheque #{cheque.numero}!\n* #{cheque.errors.full_messages.join("\n")}")

            Movimento.lanca_contabilidade(ano, [
                {:conta => cheque.parcela.conta, :historico => parametros["historico"],
                  :numero_de_controle => cheque.parcela.conta.numero_de_controle,
                  :data_lancamento => parametros["data_abandono"],
                  :tipo_lancamento => "E", :tipo_documento => cheque.parcela.conta.tipo_de_documento,
                  :provisao => 0, :pessoa => cheque.parcela.conta.pessoa, :parcela => cheque.parcela,
                  :numero_da_parcela => cheque.parcela.numero, :cheque => true, :situacao_cheque => cheque.situacao},
                [{:plano_de_conta => PlanoDeConta.find_by_id(parametros["conta_contabil_debito_id"]),
                    :centro => cheque.parcela.conta.centro, :valor => cheque.parcela.valor_liquido,
                    :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}],
                [{:plano_de_conta => PlanoDeConta.find_by_id(parametros["conta_contabil_credito_id"]),
                    :centro => cheque.parcela.conta.centro, :valor => cheque.parcela.valor_liquido,
                    :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}]],
              unidade.id)
            
            HistoricoOperacao.cria_follow_up("O cheque #{cheque.numero} foi enviado ao DR", usuario_corrente, cheque.parcela.conta, nil, nil, cheque.parcela.valor_liquido)
          else
            raise("A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.")
          end
        end
        [true, "Cheque enviado ao DR com sucesso!"]
      end  
    rescue Exception => e
      [false, e.message]
    end
  end

  def self.devolver(ano, params, params_unidade, usuario_corrente)
    begin
      exceptions = []
      Cheque.transaction do
        exceptions << "* Selecione uma Conta Contábil válida" if params["conta_contabil_devolucao_id"].blank?
        exceptions << "* Selecione uma alínea válida" if params["alinea"].blank?
        exceptions << "* O campo histórico deve ser preenchido" if params["historico"].blank?
        exceptions << "* O campo de data deve ser preenchido" if params["data_do_evento"].blank?
        exceptions << "* Selecione pelo menos um cheque para executar a devolução" if params["ids"].blank?
        raise exceptions.join("\n") unless exceptions.blank?
        params['ids'].each do |id|
          unidade = Unidade.find params_unidade rescue raise 'Unidade inválida!'
          cheque = Cheque.find id, :include => [:parcela_recebimento_de_conta => :conta],
            :conditions => ["(cheques.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)", [BAIXADO, REAPRESENTADO], unidade.id] rescue raise("O cheque selecionado não pode ser devolvido!")

          if cheque.data_limite_valida_de_operacao?(params['data_do_evento'].to_date) || cheque.validar_data_de_operacao_entre_periodo(params['data_do_evento'].to_date)
            cheque.historico = params['historico']
            cheque.conta_contabil_devolucao_id = params["conta_contabil_devolucao_id"]
            cheque.data_do_deposito = nil
            cheque.data_devolucao = params['data_do_evento']
            cheque.situacao = DEVOLVIDO
            cheque.save || raise("Não foi possível devolver o cheque #{cheque.numero}!\n* #{cheque.errors.full_messages.join("\n")}")

            unless params.has_key?("estornar")
              Movimento.lanca_contabilidade(ano, [
                  {:conta => cheque.parcela.conta, :historico => params["historico"],
                    :numero_de_controle => cheque.parcela.conta.numero_de_controle,
                    :data_lancamento => params["data_do_evento"], :tipo_lancamento => "E",
                    :tipo_documento => cheque.parcela.conta.tipo_de_documento, :provisao => 0,
                    :pessoa => cheque.parcela.conta.pessoa, :numero_da_parcela => cheque.parcela.numero,
                    :parcela => cheque.parcela, :cheque => true, :situacao_cheque => cheque.situacao},
                  [{:plano_de_conta => PlanoDeConta.find_by_id(params["conta_contabil_devolucao_id"]),
                      :centro => cheque.parcela.conta.centro, :valor => cheque.parcela.valor_liquido,
                      :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}],
                  [{:plano_de_conta => cheque.conta_contabil, :centro => cheque.parcela.conta.centro,
                      :valor => cheque.parcela.valor_liquido,
                      :unidade_organizacional => cheque.parcela.conta.unidade_organizacional}]],
                unidade.id)

              ocorrencia = OcorrenciaCheque.new(:cheque => cheque, :data_do_evento => params["data_do_evento"].to_date,
                :tipo_da_ocorrencia => params["tipo_da_ocorrencia"], :alinea => params["alinea"], :historico => params['historico'])
              ocorrencia.save!
            end
            
            HistoricoOperacao.cria_follow_up("O cheque #{cheque.numero} foi devolvido", usuario_corrente, cheque.parcela.conta, nil, nil, cheque.parcela.valor_liquido)
          else
            raise("A operação não pode ser efetuada pois o limite de dias retroativos foi excedido.")
          end
        end
        [true,"Cheque devolvido com sucesso!"]
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def self.retorna_cheques_para_relatorio(params,unidade)
    return [] if params["filtro"].blank? || params["periodo"].blank?
    
    @sqls = ['recebimento_de_contas.unidade_id = ?']
    @variaveis = [unidade]

    if params["periodo"] == 'recebimento'
      sql = 'parcelas.data_da_baixa'
    elsif params["periodo"] == 'vencimento'
      sql = 'parcelas.data_vencimento'
    elsif params["periodo"] == 'baixa'
      sql = 'cheques.data_do_deposito'
    end

    preencher_array_para_buscar_por_faixa_de_datas params, 'periodo', sql

    unless params["situacao"].blank?
      @sqls << 'cheques.situacao IN (?)'
      case params["situacao"]
      when '1'; @variaveis << GERADO;
      when '2'; @variaveis << BAIXADO;
      end
    end

    case params["filtro"]
    when "1";
      @sqls << "cheques.prazo = ?"
      @variaveis << VISTA
    when "2";
      @sqls << "cheques.prazo = ?"
      @variaveis << PRAZO
    when "3";
      @sqls << "cheques.situacao = ?"
      @variaveis << DEVOLVIDO
    when "4";
      @sqls << "cheques.situacao = ?"
      @variaveis << BAIXADO
    end

    Cheque.all(:include => [:parcela_recebimento_de_conta => :conta], :conditions => ([@sqls.join(' AND ')] + @variaveis), :order => params["ordenacao"])
  end

  def unidade
    self.parcela.unidade
  end
  
end
