module ContaPagarReceber

  Sim = 1
  Nao = 0

  OPCAO_PARA_SELECT = [['SIM', Sim], ['NÃO', Nao]]

  TIPOS_DE_DOCUMENTO = [['CPMF','CPMF'],
    ['SERVIÇOS EDUCACIONAIS - CONTRATO RECEBIMENTO','CTRSE'],
    ['SERVIÇOS TEC. TECNOLÓGICOS - CONTRATO RECEBIMENTO','CTRST'],
    ['CHPRE - CHEQUE PRÉ-DATADO','CHPRE'],
    ['CTP - CONTRATO - PAGAMENTO','CTP'],
    ['CTR - CONTRATO - RECEBIMENTO','CTR'],
    ['CTREV - EVENTOS - CONTRATO RECEBIMENTO','CTREV'],
    ['DESPESAS BANCÁRIAS ','DB'],
    ['NF - NOTA FISCAL','NF'],
    ['NFS - NOTA FISCAL DE SERVIÇOS','NFS'],
    ['NTE - NUMERÁRIO EM TRÂNSITO ENTRADA','NTE'],
    ['NTS - NUMERÁRIO EM TRÂNSITO SAÍDA','NTS'],
    ['OP - ORDEM PAGAMENTO','OP'],
    ['OR - ORDEM RECEBIMENTO','OR'],
    ['RPA - RECIBO PAGAMENTO AUTÔNOMO','RPA'],
    ['TRE - TRANSFERÊNCIAS ENTRE CONTAS - ENTRADA','TRE'],
    ['TRS - TRANSFERÊNCIAS ENTRE CONTAS - SAÍDAS','TRS'],
    ['CTRC - CONHECIMENTO TRANSP. RODOV. CARGAS','CTRC']]

  def monta_numero_de_controle_se_necessario
    if self.numero_de_controle.blank? && self.unidade && !self.tipo_de_documento.blank?
      prefixo_do_numero = "#{ self.unidade.sigla }-#{ self.tipo_de_documento }#{ Date.today.strftime("%m/%y") }"
      self.numero_de_controle = Gefin.monta_numeros_de_controle(prefixo_do_numero)
    end
  end

  def todas_baixadas?
    self.parcelas.blank? ? false : self.parcelas.all? {|parcela| parcela.data_da_baixa != nil }
  end

  def alguma_parcela_baixada?
    self.parcelas.any?{|parcela| parcela.data_da_baixa != nil}
  end

  module ClassMethods
  end

  def self.included(base)
    base.validates_presence_of :unidade, :ano, :pessoa, :valor_do_documento_em_reais, :historico, :unidade_organizacional, :centro
    base.validates_inclusion_of :tipo_de_documento, :in => TIPOS_DE_DOCUMENTO.collect(&:last), :message => 'é inválido'
    base.validates_inclusion_of :rateio, :in => [0, 1], :message => 'é inválido.'
    base.validates_numericality_of :valor_do_documento, :numero_de_parcelas, :greater_than => 0, :message => 'deve ser maior do que zero.'
    base.attr_protected :unidade_id, :ano, :parcelas_geradas, :numero_de_controle
    base.attr_writer_public :valor_do_documento_em_reais, :nome_pessoa, :nome_centro, :nome_unidade_organizacional
    base.attr_accessor_public :usuario_corrente,:mensagem_de_erro
    base.belongs_to :centro
    base.belongs_to :unidade
    base.belongs_to :unidade_organizacional
    base.belongs_to :pessoa
    base.before_validation :monta_numero_de_controle_se_necessario
    base.has_many :historico_operacoes, :as => :conta, :dependent=>:destroy, :order => 'created_at ASC'
    base.has_many :parcelas, :as => :conta, :order => "numero", :dependent=>:destroy
    base.has_many :movimentos, :as => :conta, :dependent => :destroy
    base.has_many :compromissos, :as => :conta, :dependent => :destroy
    base.has_many :parcelas_em_aberto, :class_name => 'Parcela', :as => :conta, :order => 'numero', :conditions => 'data_da_baixa IS NULL AND situacao IN (1, 5, 6, 7, 8, 9, 10)'
    base.has_many :parcelas_em_aberto_ordenadas, :class_name => 'Parcela', :as => :conta, :conditions => 'data_da_baixa IS NULL AND situacao IN (1, 5, 6, 7, 8, 9, 10)'
    base.has_many :parcelas_em_aberto_ordenadas_por_vencimento, :class_name => 'Parcela', :as => :conta, :order => 'data_vencimento ASC', :conditions => 'data_da_baixa IS NULL AND situacao IN (1, 5, 6, 7, 8, 9, 10)'
    base.has_many :parcelas_renegociadas, :class_name => 'Parcela', :as => :conta, :conditions => 'situacao = 4'
    base.validates_uniqueness_of :numero_de_controle, :scope => :unidade_id, :message => 'já esta em uso para essa unidade.'
    base.extend(ClassMethods)
    base.verifica_se_centro_pertence_a_unidade_organizacional :centro, :unidade_organizacional
    base.valida_anos_centro_e_unidade_organizacional :centro, :unidade_organizacional
    base.cria_readers_e_writers_para_valores_em_dinheiro :valor_do_documento
    base.cria_readers_e_writers_para_o_nome_dos_atributos :unidade_organizacional, :centro, :pessoa
  end

  def before_destroy
    if alguma_parcela_baixada?
      self.mensagem_de_erro = 'Não foi possível deletar este documento, pois ele possui parcelas baixadas'
      return false
    end
  end

  def gerar_nova_data_de_vencimento(data, vencimento)
    begin
      data = data.to_date
      #mes = data.day > vencimento ? data.month + 1 : data.month
      mes = vencimento > data.day ? data.month : data.month + 1
      Date.new((mes == 13 ? data.year + 1 : data.year), (mes == 13 ? 1 : mes), vencimento)
    rescue
      data + 1.day
    end
  end

  def gerar_nova_data_de_vencimento_renegociacao(data, vencimento)
    begin
      data = data.to_date
      mes = data.month + 1
      Date.new((mes == 13 ? data.year + 1 : data.year), (mes == 13 ? 1 : mes), vencimento)
    rescue
      data + 1.day
    end
  end

  def gerar_parcelas(ano)
    begin
      self.class.transaction do
        vencimento = self.is_a?(PagamentoDeConta) ? self.primeiro_vencimento : self.gerar_nova_data_de_vencimento(self.data_inicio, self.dia_do_vencimento)
        numero_de_parcelas = self.numero_de_parcelas rescue 1
        valor_total_do_documento = self.valor_do_documento / 100.0
        if self.is_a?(PagamentoDeConta) && self.provisao == 1 && !self.parcelas.blank?
          self.movimentos.each{|movimento| movimento.destroy}
        end
        self.parcelas.each{|parcela| parcela.destroy if parcela.verifica_situacoes}
        1.upto(self.numero_de_parcelas) do |numero|
          valor_parcela = valor_total_do_documento / numero_de_parcelas
          valor_parcela = format("%.2f", valor_parcela).to_f
          valor_total_do_documento = valor_total_do_documento - valor_parcela
          numero_de_parcelas = numero_de_parcelas - 1
          valor_final_parcela = valor_parcela * 100
					#if self.is_a?(RecebimentoDeConta)
            #valor_vencimento = (vencimento + 1.month)
					#else
						valor_vencimento = vencimento
					#end
          parce = self.parcelas.create! :valor => valor_final_parcela.round, :data_vencimento => valor_vencimento , :numero => numero, :situacao => self.atribui_situacao
          vencimento = vencimento.to_date + 1.month
          if self.is_a?(PagamentoDeConta)
            Rateio.create! :parcela => parce, :unidade_organizacional => self.unidade_organizacional, :centro => self.centro, :conta_contabil => self.conta_contabil_despesa, :valor => parce.valor if self.rateio == 1
            Movimento.lanca_contabilidade(ano, [
                {:conta => self, :historico => self.historico, :numero_de_controle => self.numero_de_controle,
                  :data_lancamento => self.data_emissao, :tipo_lancamento => 'E', :tipo_documento => self.tipo_de_documento, :provisao => Movimento::PROVISAO, :unidade => self.unidade,
                  :pessoa => self.pessoa, :numero_da_parcela => numero, :parcela_id => parce.id},
                [{:plano_de_conta => self.conta_contabil_despesa, :centro => self.centro, :valor => valor_final_parcela.round, :unidade_organizacional => self.unidade_organizacional}],
                [{:plano_de_conta => self.conta_contabil_pessoa, :centro => self.centro, :valor => valor_final_parcela.round, :unidade_organizacional => self.unidade_organizacional}]
              ], self.unidade_id) if self.provisao == PagamentoDeConta::SIM
          else
            Rateio.create! :parcela => parce, :unidade_organizacional => self.unidade_organizacional, :centro => self.centro, :conta_contabil => self.conta_contabil_receita, :valor => parce.valor if self.rateio == 1
          end
        end
        self.parcelas.reload
        HistoricoOperacao.cria_follow_up("Geradas #{self.parcelas.length} parcelas", self.usuario_corrente, self)
        [true, 'Parcelas geradas com sucesso!']
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def pode_gerar_parcelas
    return true if self.is_a?(RecebimentoDeConta) && !self.pode_ser_modificado? && self.parcelas.length == 0    
  end

  def atribui_situacao
    if self.is_a?(RecebimentoDeConta)
      situacao_parcela = nil
      case self.situacao_fiemt
      when RecebimentoDeConta::Normal; situacao_parcela = Parcela::PENDENTE
      when RecebimentoDeConta::Juridico; situacao_parcela = Parcela::JURIDICO
      when RecebimentoDeConta::Permuta; situacao_parcela = Parcela::PERMUTA
      when RecebimentoDeConta::Baixa_do_conselho; situacao_parcela = Parcela::BAIXA_DO_CONSELHO
      when RecebimentoDeConta::Desconto_em_folha; situacao_parcela = Parcela::DESCONTO_EM_FOLHA
      end
      situacao_parcela
    else
      situacao_parcela = Parcela::PENDENTE
    end
  end

  def tamanho_campo_historico
    self.historico.length > 254 ? true : false
  end

end
