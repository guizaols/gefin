class PagamentoDeConta < ActiveRecord::Base
  include ContaPagarReceber

  acts_as_audited

  SIM = 1
  NAO = 0 
  OPCAO_PARA_SELECT = [['SIM', SIM], ['NÃO', NAO]]
  MENSAGENS_POR_ALERT = 7

  acts_as_audited
  validates_inclusion_of :provisao, :in => [Sim, Nao],:message => "é inválido."
  data_br_field :primeiro_vencimento,:data_lancamento,:data_emissao
  validates_presence_of :primeiro_vencimento, :conta_contabil_despesa, :message => "é inválido."
  validates_presence_of :conta_contabil_pessoa,:if => Proc.new {|conta| conta.provisao == Sim },:message=>"é inválido."
  validates_presence_of :data_lancamento, :message => "deve ser preenchido."
  attr_accessor :sigla_unidade, :nome_conta_contabil_pessoa, :conta_contabil_pessoa_id_parametrizada, :ano_contabil_atual, :atualizando_parcelas, :mensagem_de_erro
  belongs_to :conta_contabil_despesa,:class_name=>'PlanoDeConta',:foreign_key=>"conta_contabil_despesa_id"
  belongs_to :conta_contabil_pessoa,:class_name=>'PlanoDeConta',:foreign_key=>"conta_contabil_pessoa_id"
  converte_para_data_para_formato_date :data_emissao,:data_lancamento, :primeiro_vencimento
  possui_conta_contabil_parametrizada :conta_contabil_pessoa_id, ParametroContaValor::FORNECEDOR, "Conta Contábil do Fornecedor inválida, está conta já está parametrizada"
  cria_readers_e_writers_para_o_nome_dos_atributos :conta_contabil_despesa

  
  
  HUMANIZED_ATTRIBUTES = {
    :tipo_de_documento => "O campo tipo de documento",
    :provisao => "O campo provisão",
    :rateio => "O campo rateio",
    :pessoa => "O campo fornecedor",
    :centro => "O campo centro",
    :ano => "O campo ano",
    :valor_do_documento_em_reais => "O campo valor do documento",
    :plano_de_conta => "O campo conta contábil despesa",
    :plano_de_conta_fornecedor => "O campo conta contábil fornecedor",
    :data_lancamento => "O campo data de lançamento",
    :unidade_organizacional => "O campo unidade organizacional",
    :data_emissao => "O campo data da emissão",
    :unidade => "O campo unidade",
    :valor_do_documento => "O campo valor",
    :numero_de_parcelas => "O campo parcelas",
    :numero_nota_fiscal_string => "O campo número da nota fiscal",
    :primeiro_vencimento => "O campo primeiro vencimento",
    :historico => "O campo histórico"
  }
  
  def initialize(attributes = {})
    super attributes
    if attributes[:primeiro_vencimento].blank? && attributes[:data_lancamento].blank? && attributes[:data_emissao].blank? && attributes[:parcelas_geradas].blank?
      self.primeiro_vencimento = Date.today
      self.data_lancamento = Date.today
      self.data_emissao = Date.today
      self.parcelas_geradas = false
      self.atualizando_parcelas = false
      if conta = conta_contabil_pessoa_id_parametrizada(attributes[:ano], attributes[:unidade_id])
        self.conta_contabil_pessoa_id = conta
        self.ano = attributes[:ano]
        self.unidade_id = attributes[:unidade_id]
      end
    end
  end

  def after_update
    if (self.numero_de_parcelas_changed? || self.valor_do_documento_changed?) && !alguma_parcela_baixada? && !self.atualizando_parcelas
      self.parcelas.each{|parcela| parcela.destroy if parcela.situacao != Parcela::CANCELADA}
      self.movimentos.each{|movimento| movimento.destroy}
      self.gerar_parcelas(ano_contabil_atual)
    end
    # Agora deixa alterar provisão com parcelas baixadas
    if (self.provisao_changed? && self.parcelas.length > 0)
      if self.provisao_was == SIM && self.provisao == NAO
        movimentos_da_conta = Movimento.find(:all, :conditions => ["conta_id = ? AND conta_type = ? AND provisao = ?", self.id, "PagamentoDeConta", Movimento::PROVISAO])
        movimentos_da_conta.each do |movimento|
          movimento.destroy
        end
      elsif self.provisao_was == NAO && self.provisao == SIM
        self.parcelas.each do |parcela|
          parcela.destroy
        end
        self.gerar_parcelas(ano_contabil_atual)
      end
    end
  end

  def before_save
    self.conta_contabil_pessoa_id = nil if self.provisao == 0
  end

  def validate_on_create
    errors.add :pessoa, "deve conter uma pessoa do tipo fornecedor" if (!self.pessoa.blank? && self.pessoa.fornecedor != true)
  end

  def after_validation
    if self.liberacao_dr_faixa_de_dias_permitido == true
      self.liberacao_dr_faixa_de_dias_permitido = false
    end
  end
  
  def excluir_contrato
    if self.parcelas.length == 0
      self.movimentos.each{|mov| mov.destroy} if self.provisao == SIM
      self.destroy
    else
      false
    end
  end

  def before_destroy
    if self.alguma_parcela_baixada?
      self.mensagem_de_erro = 'O contrato não pode ser excluído porque possui uma ou mais parcelas com a situação Quitada!'
      return false
    end
    if self.liberacao_dr_faixa_de_dias_permitido != true && self.parcelas.length > 0 
      if !esta_dentro_da_faixa_de_dias_permitido?(self.data_emissao.to_date) && !validar_data_inicio_entre_limites
        self.mensagem_de_erro = "Não foi possível excluir o contrato, pois a data de emissão excedeu o limite máximo permitido"
        return false
      end
    end
  end

  def validate
    errors.add :data_emissao, 'não pode ser maior do que a data de hoje' if self.data_emissao.to_date > Date.today
    errors.add :historico, 'não pode ser possuir um valor com mais de 254 caracteres' if tamanho_campo_historico
    unless self.new_record?
      if self.alguma_parcela_baixada?
        errors.add :provisao, "não pode ser alterado após alguma parcela ser baixada." if self.provisao_changed?
        errors.add :rateio, "não pode ser alterado após alguma parcela ser baixada." if self.rateio_changed?
        errors.add :valor_do_documento, "não pode ser alterado após alguma parcela ser baixada." if self.valor_do_documento_changed?
        errors.add :numero_de_parcelas, "não pode ser alterado após alguma parcela ser baixada." if self.numero_de_parcelas_changed?
      end
    end
    if self.liberacao_dr_faixa_de_dias_permitido != true
      if !esta_dentro_da_faixa_de_dias_permitido?(self.data_emissao.to_date) && !validar_data_inicio_entre_limites
        errors.add :data_emissao, "excedeu o limite máximo permitido"
      end
    end
    
    #errors.add :base, "Conta Contábil do Fornecedor inválida, está conta já está parametrizada" if  self.conta_contabil_pessoa && self.conta_contabil_pessoa_id_parametrizada && (self.conta_contabil_pessoa_id != self.conta_contabil_pessoa_id_parametrizada.conta_contabil_id)
    errors.add :base, "Conta Contábil do Fornecedor inválida, selecione uma conta sintética" if self.conta_contabil_pessoa && self.conta_contabil_pessoa.tipo_da_conta == 0
    errors.add :base, "Conta Contábil de Despesa inválida, selecione uma conta sintética" if self.conta_contabil_despesa && self.conta_contabil_despesa.tipo_da_conta == 0
    errors.add :base, "O campo número de parcelas não pode ser alterado após uma parcela ter sido baixada." if self.alguma_parcela_baixada? && self.numero_de_parcelas_changed? 
    errors.add :base, "O campo valor do documento não pode ser alterado após uma parcela ter sido baixada." if self.alguma_parcela_baixada? && self.valor_do_documento_changed?
    #errors.add :base, "Não é possível alterar a provisão deste contrato. Suas parcelas já foram geradas." if self.parcelas.length > 0 && self.provisao_changed?
    errors.add :base, "Não é possível alterar o nome do cliente, pois este contrato já possui parcelas baixadas" if nao_pode_alterar_dados_do_cliente_em_contrato?
  end
  
  def nome_conta_contabil_pessoa
    conta_contabil_pessoa.try :retorna_codigo_contabil_e_descricao
  end

  def nao_pode_alterar_dados_do_cliente_em_contrato?
    if !self.new_record? && self.alguma_parcela_baixada? && self.pessoa_id_changed?
      true #Quando não for um novo registro e já tiver parcela baixada não pode alterar o nome do cliente
    else
      false
    end
  end
  
  def after_create
    HistoricoOperacao.cria_follow_up("Conta a pagar criada", @usuario_corrente, self, nil, nil, self.valor_do_documento)
  end

  def self.pesquisa_simples(unidade_id, parametros, page = nil)
    busca = parametros['texto'].formatar_para_like
    if parametros['ordem'] == 'situacao' || parametros['ordem'].blank?
      ordem = 'primeiro_vencimento'
    else
      ordem = parametros['ordem']
      cpf_cnpj = parametros['texto'].gsub(/[\.\-\/]/, '')
    end
    if parametros.blank?
      resultado = []
    else
    resultado = self.all :conditions => ["(pagamento_de_contas.unidade_id = ?) AND ((pagamento_de_contas.numero_de_controle like ?) OR (pessoas.nome like ?) OR (pessoas.razao_social like ?) OR (pessoas.cpf like ?) OR (pessoas.cnpj like ?)  OR (pessoas.cpf like ?) OR (pessoas.cnpj like ?))", unidade_id, busca, busca, busca, busca, busca, cpf_cnpj, cpf_cnpj],
      :include => [:pessoa],
      :order => ordem
    end
    
    resultado = resultado.sort_by(&:situacao_parcelas) if parametros['ordem'] == 'situacao'
    resultado.paginate :page => page, :per_page => 50
  end

  def esta_dentro_da_faixa_de_dias_permitido?(data)
    return true if data.blank? || unidade.blank?
    if (data.to_date) >= (Date.today - unidade.lancamentoscontaspagar)
      true
    else
      false
    end
  end

  def validar_data_inicio_entre_limites
    return true if self.data_lancamento.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if self.data_lancamento.to_date.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end
  
  def esta_dentro_da_faixa_de_dias_permitido_para_estorno?(data)
    return true if data.blank? || unidade.blank?
    if (data.to_date) >= (Date.today - unidade.limitediasparaestornodeparcelas)
      true
    else
      false
    end
  end
  
  def validar_data_entre_limites(data)
    return true if data.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if data.to_date.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def situacao_parcelas
    return 'Pendente' if parcelas.empty?
    if parcelas.all?{|p| p.situacao == Parcela::QUITADA || p.situacao == Parcela::CANCELADA}
      'Quitada'
    elsif parcelas.any?{|p| p.situacao == Parcela::PENDENTE && p.situacao_verbose == "Em atraso"}
      'Em atraso'
    elsif parcelas.any?{|p| p.situacao == Parcela::PENDENTE && p.situacao_verbose == "Vincenda"}
      'Pendente'
    elsif parcelas.any?{|p| p.situacao == Parcela::JURIDICO}
      'Jurídico'
    elsif parcelas.any?{|p| p.situacao == Parcela::PERMUTA}
      'Permuta'
    elsif parcelas.any?{|p| p.situacao == Parcela::BAIXA_DO_CONSELHO}
      'Baixa do Conselho'
    elsif parcelas.any?{|p| p.situacao == Parcela::DESCONTO_EM_FOLHA}
      'Desconto em Folha'
    elsif parcelas.any?{|p| p.situacao == Parcela::ESTORNADA}
      'Estornada'
    end
  end

  def criar_follow_up_update(object, usuario)
    mensagens = []
    mensagens << "Conta a pagar Alterada"
    mensagens << "A Conta Contábil Despesa foi alterada de '#{object.conta_contabil_despesa.codigo_contabil} - #{object.conta_contabil_despesa.nome}' para '#{self.conta_contabil_despesa.codigo_contabil} - #{self.conta_contabil_despesa.nome}'." if self.conta_contabil_despesa_id != object.conta_contabil_despesa_id
    mensagens << "A Unidade Organizacional foi alterada de '#{object.unidade_organizacional.codigo_da_unidade_organizacional} - #{object.unidade_organizacional.nome}' para '#{self.unidade_organizacional.codigo_da_unidade_organizacional} - #{self.unidade_organizacional.nome}'." if self.unidade_organizacional_id != object.unidade_organizacional_id
    mensagens << "O Centro foi alterado de '#{object.centro.codigo_centro} - #{object.centro.nome}' para '#{self.centro.codigo_centro} - #{self.centro.nome}'." if self.centro_id != object.centro_id
    mensagens.each do |mensagem|
      HistoricoOperacao.cria_follow_up(mensagem, usuario, self, nil, nil, self.valor_do_documento)
    end
  end

  def verifica_contratos(entidade_id, data, fornecedor)
    cabecalho = "Este são alguns dos contratos que este cliente possui vigentes neste mês:\n\n
UNIDADE                          Nº CONTROLE\n1º VENCIMENTO  VALOR   SITUAÇÃO  EMISSÃO\n\n"
    footer = "\n... e podem existir outros contratos, favor verificar!\n\n"
    paginas = []
    resultado = []

    contas = PagamentoDeConta.find(:all, :include => [:unidade => :entidade], :conditions => ['(entidades.id = ?) AND (pagamento_de_contas.pessoa_id = ?) AND (MONTH(pagamento_de_contas.primeiro_vencimento) = ? AND YEAR(pagamento_de_contas.primeiro_vencimento) = ?) AND (1=1)', entidade_id, fornecedor, data.to_date.month, data.to_date.year], :order => 'pagamento_de_contas.data_lancamento DESC', :limit => 5)
    unless contas.blank?
      contas.each_with_index do |conta, idx|
        unless conta == self
          unless conta.parcelas.blank?
            linha = conta.unidade.nome.to_s[0..19]
            linha = linha+'                                                  '[0..((20-linha.size)*2+linha.count(' ')+linha.count('-')+linha.count('.'))]
            linha << conta.numero_de_controle.to_s[0..30].ljust(31)+"\n"
            linha << conta.data_emissao.to_s+"\n"
            linha << conta.valor_do_documento_em_reais.to_s[0..7].rjust(8)+"   "
            linha << conta.situacao_parcelas.to_s[0..10].ljust(12)
            linha << conta.primeiro_vencimento.to_s[0..9].ljust(10)+"\t"+'         '[0..(8-conta.valor_do_documento_em_reais.to_s.size)]
            resultado << linha
            if (contas.length - 1) == idx
              resultado << footer
            end
            if (idx % MENSAGENS_POR_ALERT == MENSAGENS_POR_ALERT - 1)
              paginas << (cabecalho + resultado).join("\n")
              resultado = []
            end
          end
        end
      end
      paginas << cabecalho + resultado.join("\n") unless resultado.empty?
      return paginas
    end
    ''
  end

  # RF4
  def atualizar_valor_das_parcelas(ano, params, usuario)
    soma_parcelas = 0
    begin
      self.atualizando_parcelas = true
      PagamentoDeConta.transaction do
        return 'A soma do valor das parcelas não é igual ao valor das parcelas pendentes' if valores_das_parcelas_sao_diferentes?(params)
        retorno_da_funcao = datas_estao_incorretas?(params)
        return retorno_da_funcao.last if retorno_da_funcao.first
        params.each do |id, conteudo|
          parcela = Parcela.find_by_id_and_conta_id id.to_i, self.id
          unless [Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(parcela.situacao)
            atributos = {:valor => (conteudo["valor"].real.to_f * 100), :data_vencimento => conteudo["data_vencimento"]}
            soma_parcelas += conteudo["valor"].real.to_f * 100
            if self.rateio == 1
              refaz_proporcionalmente_o_rateio(atributos, parcela)
              resultado = parcela.grava_itens_do_rateio(ano, usuario, true)
              if resultado.first != true
                raise resultado.last
              end
            else
              HistoricoOperacao.cria_follow_up("A parcela #{parcela.numero} foi alterada", usuario, parcela.conta, nil, nil, parcela.valor)
              parcela.update_attributes!(atributos)
            end
          end
        end
        #self.update_attribute(:valor_do_documento, soma_parcelas)
        return true
      end
    rescue Exception => e
      e.to_s
    end
  end

  # RF4
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

  # RF4
  def valores_das_parcelas_sao_diferentes?(params)
    soma = 0
    params.each do |id, conteudo|
      parcela = Parcela.find_by_id_and_conta_id(id.to_i, self.id)
      if parcela.situacao != Parcela::QUITADA
        soma += (conteudo["valor"].gsub(".", "").gsub(",", ".")).to_f * 100
      end
    end
    #soma = params.sum { |_, conteudo| (conteudo["valor"].gsub(".", "").gsub(",", ".")).to_f * 100 }
    soma_das_parcelas_pendentes = parcelas.sum(:valor, :conditions => {:situacao => Parcela::PENDENTE})
    soma.to_i != soma_das_parcelas_pendentes
  end

  # RF4
  def datas_estao_incorretas?(params)
    params.each do |chave, conteudo|
      return [true, "A data de vencimento deve ser preenchida."] if conteudo["data_vencimento"].blank?
      return [true, "O valor deve ser preenchido."] if conteudo["valor"].blank?
      return [true, "A parcela com data de vencimento #{conteudo["data_vencimento"]} é inválida, pois o primeiro vencimento do contrato é em #{self.primeiro_vencimento}"] if (conteudo["data_vencimento"].to_date < self.primeiro_vencimento.to_date)
    end
    return [false, nil]
  end

  # RF4
  def refaz_proporcionalmente_o_rateio(dados, parcela)
    valor_das_porcentagens = []
    soma = 0; soma_imposto = 0
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
      unless parcela.dados_do_imposto[chave.to_s].blank?
        soma_imposto += parcela.dados_do_imposto[chave.to_s]["valor_imposto"].to_i * 100
      end
      raise 'Valor dos impostos maior ou igual ao valor da parcela. Impossível salvar por favor verifique.' if soma_imposto >= parcela.valor
    end
  end

  def estornar_provisao_pagamento(params, parcela_id, usuario_id)
    excecoes = []
    data = params['data_estorno']
    begin
      PagamentoDeConta.transaction do
        if self.provisao == NAO
          parcela = Parcela.find_by_id(parcela_id) || raise("A parcela com ID #{parcela_id} não existe!")
          usuario = Usuario.find_by_id(usuario_id) || raise("O usuario com ID #{usuario_id} não existe!")
          if ![Parcela::QUITADA, Parcela::CANCELADA].include?(parcela.situacao) && parcela.situacao != Parcela::ESTORNADA
            parcela.situacao = Parcela::ESTORNADA
            parcela.save!
            HistoricoOperacao.cria_follow_up("A parcela #{parcela.numero} teve sua provisão estornada!", usuario, self, params['justificativa'], nil, self.valor_do_documento)
            [true, "A parcela #{parcela.numero} teve sua provisão estornada!"]
          elsif [Parcela::QUITADA, Parcela::CANCELADA].include?(parcela.situacao)
            [false, "A parcela está com a situação #{parcela.situacao_verbose} e não pode ser estornada!"]
          else
            parcela.situacao = Parcela::PENDENTE
            parcela.save!
            HistoricoOperacao.cria_follow_up("A parcela #{parcela.numero} teve sua provisão de volta ao normal!", usuario, self, params['justificativa'], nil, self.valor_do_documento)
            [true, "A parcela #{parcela.numero} teve sua provisão de volta ao normal!"]
          end
        else
          excecoes << '* O campo Data do Estorno é obrigatório' if data.blank?
          excecoes << '* O campo Justificativa é obrigatório' if params['justificativa'].blank?
          excecoes << '* A Data do Estorno não pode ser maior que a data de hoje' if data.to_date > Date.today
          unless excecoes.blank?
            return [false, excecoes.join("\n")]
          else
            if self.liberacao_dr_faixa_de_dias_permitido != true
              if !esta_dentro_da_faixa_de_dias_permitido_para_estorno?(data) && !validar_data_entre_limites(data)
                return [false, 'Não foi possível estornar a provisão desta parcela, pois a data escolhida para o estorno excedeu o limite máximo permitido']
              else
                parcela = Parcela.find_by_id(parcela_id) || raise("A parcela com ID #{parcela_id} não existe!")
                usuario = Usuario.find_by_id(usuario_id) || raise("O usuario com ID #{usuario_id} não existe!")
                if ![Parcela::QUITADA, Parcela::CANCELADA].include?(parcela.situacao) && parcela.situacao != Parcela::ESTORNADA
                  parcela.situacao = Parcela::ESTORNADA
                  parcela.save!

                  movimento = Movimento.find_by_parcela_id_and_provisao(parcela.id, Movimento::PROVISAO)
                  movimento_estorno = movimento.clone
                  movimento_estorno.historico = parcela.conta.historico + ' (Estornado)'
                  movimento_estorno.tipo_lancamento = 'N'
                  movimento_estorno.data_lancamento = data.to_date
                  movimento.itens_movimentos.each do |item|
                    movimento_estorno.itens_movimentos << item.clone
                  end
                  movimento_estorno.itens_movimentos.each do |it|
                    it.tipo = it.tipo == 'C' ? 'D' : 'C'
                    it.save!
                  end
                  movimento_estorno.save!

                  HistoricoOperacao.cria_follow_up("A parcela #{parcela.numero} teve sua provisão estornada!", usuario, self, params['justificativa'], nil, self.valor_do_documento)
                  [true, "A parcela #{parcela.numero} teve sua provisão estornada!"]
                elsif [Parcela::QUITADA, Parcela::CANCELADA].include?(parcela.situacao)
                  [false, "A parcela está com a situação #{parcela.situacao_verbose} e não pode ser estornada!"]
                else
                  parcela.situacao = Parcela::PENDENTE
                  parcela.save!
                  parcela.remove_movimento_e_itens_com_tipo_de_movimento(Movimento::PROVISAO, 'N')
                  HistoricoOperacao.cria_follow_up("A parcela #{parcela.numero} teve sua provisão de volta ao normal!", usuario, self, params['justificativa'], nil, self.valor_do_documento)
                  [true, "A parcela #{parcela.numero} teve sua provisão de volta ao normal!"]
                end
              end
            end
          end
        end
      end
    rescue Exception => e
      #p e.message
      [false, e.message]
    end
  end

end
