class Pessoa < ActiveRecord::Base

  acts_as_audited

  #CONSTANTES
  FISICA = 1
  JURIDICA = 2

  SIM = true
  NAO = false

  #VALIDAÇÕES
  validates_presence_of :endereco, :message =>"deve ser preenchido"
  validates_presence_of :razao_social, :message => 'deve ser preenchido', :if => :juridica?
  validates_presence_of :nome, :message => 'deve ser preenchido', :if => :fisica?
  validates_presence_of :entidade, :message => "deve estar preenchido."
  validates_presence_of :unidade, :message => "deve estar preenchido."
  validates_presence_of :cep, :message => "deve ser preenchido."
  validates_presence_of :banco, :if => Proc.new{|pessoa| pessoa.fornecedor?}
  validate :verifica_se_cpf_cnpj_e_unico
  validates_presence_of :cpf,:message =>"deve ser preenchido", :if=>Proc.new{|pessoa| pessoa.tipo_pessoa == FISICA}
  usar_como_cpf :cpf
  usar_como_cnpj :cnpj
  validates_presence_of :cnpj,:message =>"deve ser preenchido", :if=>Proc.new{|pessoa| pessoa.tipo_pessoa == JURIDICA}
  validates_inclusion_of :tipo_pessoa, :in => [FISICA, JURIDICA], :message =>"deve ser selecionado"
  before_validation :criar_novo_cargo

  #RELACIONAMENTOS
  has_many :dependentes, :dependent => :destroy
  #has_one :usuario, :foreign_key => "funcionario_id", :dependent => :destroy
  has_many :usuarios, :foreign_key => "funcionario_id", :dependent => :destroy
  belongs_to :localidade
  belongs_to :agencia
  belongs_to :banco
  belongs_to :entidade
  belongs_to :unidade
  has_many :pagamento_de_contas
  
  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  serialize :email
  serialize :telefone
  attr_accessor  :novo_cargo, :mensagem_de_erro, :cidade
  cria_readers_e_writers_para_o_nome_dos_atributos :localidade,:agencia
  data_br_field :data_nascimento
  converte_para_data_para_formato_date :data_nascimento
 
  
  HUMANIZED_ATTRIBUTES = {
    :cpf => 'CPF:',
    :cnpj=> 'CNPJ:',
    :cliente =>'O campo cliente',
    :fornecedor =>'O campo fornecedor',
    :funcionario =>'O campo funcionário',
    :razao_social =>'O campo razão social',
    :nome =>'O campo nome',
    :complemento=>'O campo complemento',
    :contato =>'O campo contato',
    :matricula => 'O campo matrícula',
    :tipo_pessoa =>'O campo tipo de pessoa',
    :endereco =>'O campo endereço',
    :email =>'O campo e-mail',
    :telefone =>'O campo telefone',
    :rg_ie =>'O campo RG/IE',
    :conta =>'O campo conta',
    :cep => 'O campo CEP',
    :agencia =>'O campo agência',
    :banco =>'O campo banco',
    :observacoes =>'O campo observações',
    :bairro =>'O campo bairro',
    :spc => 'O campo SPC',
    :data_nascimento => 'O campo data de nascimento',
    :entidade => 'O campo entidade',
    :industriario => 'O campo industriário',
    :localidade => 'O campo Localidade',
    :numero => "O campo Numero"
  }

  CAMPOS_PARA_IMPORTACAO = {
    0 => "cpf_cnpj",
    1 => "nome",
    2 => "endereco",
    3 => "bairro",
    4 => "cidade",
    5 => "uf",
    6 => "cep",
    7 => "fone",
    8 => "fone",
  }

  def initialize(attributes = {})
    attributes['spc'] ||= false
    super
  end

  def validate
    errors.add :base, 'Uma pessoa deve ser Cliente, Fornecedor ou Funcionário' unless (self.cliente ||self.fornecedor ||self.funcionario)
    errors.add :data_nascimento, "não existe para Pessoa Juridíca." if self.tipo_pessoa == JURIDICA && !self.data_nascimento.blank?
    errors.add :banco, "Esta agência não pertence ao #{self.banco.descricao}" if self.fornecedor && self.banco && self.banco.agencias.detect{|agencia| agencia == self.agencia}.blank?
    #if verifica_contrato_iniciado_e_baixa_de_parcela
      #errors.add :razao_social, "não pode ser alterado, pois #{self.razao_social_was.upcase rescue ''} já possui contratos em andamento!" if self.juridica? && self.razao_social_changed?
      #errors.add :nome, "não pode ser alterado, pois #{self.nome_was.upcase rescue ''} já possui contratos em andamento!" if self.fisica? && self.nome_changed?
    #end
  end

  def before_validation
    self.telefone.reject!(&:blank?)
    self.email.reject!(&:blank?)
    self.funcionario = false if tipo_pessoa == JURIDICA
    self.liberado_pelo_dr = false     if self.cliente && self.new_record?

    case tipo_pessoa
    when FISICA; self.cnpj = nil; self.razao_social = nil;
    when JURIDICA; self.cpf = nil; self.data_nascimento = nil;
    end
  end

  def before_destroy
    if possui_alguma_conta? || possui_algum_movimento_simples?
      self.mensagem_de_erro = "Não foi possível excluir a pessoa #{self.nome}, pois esta possui contas/lançamentos simples vinculadas."
      return false
    end
  end

  def possui_alguma_conta?
    conta_a_pagar = PagamentoDeConta.find_all_by_pessoa_id(self.id)
    conta_a_receber = RecebimentoDeConta.all :conditions => ["pessoa_id = ? or vendedor_id = ? or cobrador_id = ?", self.id, self.id, self.id]
    (conta_a_pagar + conta_a_receber).blank? ? false : true
  end

  def possui_algum_movimento_simples?
    Movimento.all(:conditions => ["pessoa_id = ?", self.id]).length > 0 ? true : false
  end

  def verifica_contrato_iniciado_e_baixa_de_parcela
    recebimentos = ParcelaRecebimentoDeConta.find(:all, :conditions => ['(recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.servico_iniciado = ? OR parcelas.situacao = ?)', self.id, true, Parcela::QUITADA], :include => [:conta => :pessoa])
    pagamentos = ParcelaPagamentoDeConta.find(:all, :conditions => ['(pagamento_de_contas.pessoa_id = ?) AND (parcelas.situacao = ?)', self.id, Parcela::QUITADA], :include => [:conta => :pessoa])
    (recebimentos + pagamentos).blank? ? false : true
  end

  def caption_dependente_beneficiario
    fisica? ? 'Dependente' : 'Beneficiário'
  end

  def eh_funcionario_e_esta_inativo?
    funcionario && funcionario_ativo == false
  end

  def verifica_se_cpf_cnpj_e_unico
    parametros_para_sql = []
    conteudo_para_sql = []
    if self.cpf && !self.cpf.numero.blank? && self.tipo_pessoa == Pessoa::FISICA
      parametros_para_sql << "cpf = ?"
      conteudo_para_sql << self.cpf.numero
    elsif self.cnpj && !self.cnpj.numero.blank? && self.tipo_pessoa == Pessoa::JURIDICA
      parametros_para_sql << "cnpj = ?"
      conteudo_para_sql << self.cnpj.numero
    end
    # consulta_documento = Pessoa.first :conditions => parametros_para_sql + conteudo_para_sql unless (parametros_para_sql + conteudo_para_sql).blank?
    # consulta_documento = nil if consulta_documento && ((self.id == consulta_documento.id && !self.new_record?) || consulta_documento.eh_funcionario_e_esta_inativo?)
    # errors.add :base, "O #{consulta_documento.tipo_pessoa == Pessoa::FISICA ? "CPF" : "CNPJ"} número #{consulta_documento.tipo_pessoa == Pessoa::FISICA ? consulta_documento.cpf.numero : consulta_documento.cnpj.numero} encontra-se cadastrado em nossa base de dados em nome de #{consulta_documento.tipo_pessoa == Pessoa::FISICA ? consulta_documento.nome: consulta_documento.razao_social}" unless consulta_documento.blank?

    unless (parametros_para_sql + conteudo_para_sql).blank?
      pessoas_com_mesmo_cpf = Pessoa.all :conditions => parametros_para_sql + conteudo_para_sql

      if pessoas_com_mesmo_cpf.length > 0
        resultado_da_comparacao = []
        pessoas_com_mesmo_cpf.each do |pessoa_com_mesmo_cpf|
          if pessoa_com_mesmo_cpf && ((self.id == pessoa_com_mesmo_cpf.id && !self.new_record?) || pessoa_com_mesmo_cpf.eh_funcionario_e_esta_inativo?)
            resultado_da_comparacao << nil
          else
            resultado_da_comparacao << pessoa_com_mesmo_cpf
          end
        end
        resultado_da_comparacao.compact!
        if resultado_da_comparacao.length > 0
          pessoa_com_mesmo_cpf_e_ativa = resultado_da_comparacao.first
          errors.add :base, "O #{pessoa_com_mesmo_cpf_e_ativa.tipo_pessoa == Pessoa::FISICA ? "CPF" : "CNPJ"} número #{pessoa_com_mesmo_cpf_e_ativa.tipo_pessoa == Pessoa::FISICA ? pessoa_com_mesmo_cpf_e_ativa.cpf.numero : pessoa_com_mesmo_cpf_e_ativa.cnpj.numero} encontra-se cadastrado em nossa base de dados em nome de #{pessoa_com_mesmo_cpf_e_ativa.tipo_pessoa == Pessoa::FISICA ? pessoa_com_mesmo_cpf_e_ativa.nome: pessoa_com_mesmo_cpf_e_ativa.razao_social}"
        end
      end
    end
  end
  
  def telefone
    super || []
  end

  def resumo
    nome
  end
  
  def email
    super || []
  end
  
  def label_do_campo_cpf_cnpj
    case tipo_pessoa
    when JURIDICA;" CNPJ*"
    when FISICA;"CPF*"
    else "CPF/CNPJ*"
    end
  end
  
  def label_do_campo_rg_ie
    case tipo_pessoa
    when JURIDICA;"IE*"
    when FISICA;"RG*"
    else "RG/IE*"
    end
  end
  
  def label_nome_ou_nome_fantasia
    case tipo_pessoa
    when JURIDICA;" Nome Fantasia*"
    when FISICA;" Nome*"
    else " Nome/Nome Fantasia*"
    end
  end
  
  def retorna_tipo_pessoa
    tipo_pessoa == FISICA ? 'Pessoa física' : 'Pessoa Jurídica' 
  end
  
  def criar_novo_cargo
    self.cargo = novo_cargo unless novo_cargo.blank?
  end
  
  def self.procurar_pessoas(busca, entidade, page = nil)
    busca ||={}
    parametro_para_sql = []
    conteudo_para_sql = []
    return [] if busca["conteudo"].blank? && busca["filtro"].blank? && busca["tipo"].blank?

    unless busca["filtro"].blank?
      lista_check_box = "(#{busca['filtro'].collect{|chave,campo| "#{chave} = ? "}.join(' or   ')})"
      parametro_para_sql << lista_check_box
      busca["filtro"].length.times do
        conteudo_para_sql << true
      end
    else
      parametro_para_sql << '(cliente = ? or fornecedor = ?)'
      2.times do
        conteudo_para_sql << true
      end
    end

    unless busca["tipo"].blank?
      lista_check_box = "(#{busca['tipo'].collect{|chave,campo| "#{
      if chave != "pessoa_juridica" && chave != "pessoa_fisica"
      chave
      else
      'tipo_pessoa'
      end
      } = ? "}.join('or ')})"
      parametro_para_sql << lista_check_box
      busca["tipo"].collect do |chave,campo|
        if chave != "pessoa_juridica" && chave != "pessoa_fisica"
          conteudo_para_sql << true
        else
          if chave == "pessoa_juridica"
            conteudo_para_sql << JURIDICA
          else
            conteudo_para_sql << FISICA
          end
        end
      end
    end
    unless busca["conteudo"].blank?
      parametro_para_sql << " (nome like ? or razao_social like ? or cpf like ? or contato like ? or cnpj like ?)"
      5.times do
        conteudo_para_sql << busca["conteudo"].formatar_para_like
      end
    end
    pessoas = paginate :all, :conditions =>[parametro_para_sql.join(" AND ")]+conteudo_para_sql, :order => 'nome', :page => page, :per_page => 50
    if pessoas.reject{|pessoa| pessoa.spc == false}.length > 0
      inclui_legenda = true
    else
      inclui_legenda = false
    end
    [pessoas, inclui_legenda]
  end

  def self.procurar_funcionarios(busca, unidade, page = nil)
    busca ||={}
    parametro_para_sql = []
    conteudo_para_sql = []
    return [] if busca["conteudo"].blank? && busca["tipo"].blank?

    parametro_para_sql << "funcionario = ? AND unidade_id = ?"
    conteudo_para_sql << true
    conteudo_para_sql << unidade

    unless busca["tipo"].blank?
      lista_check_box = "(#{busca['tipo'].collect{|chave, campo| "#{
      if chave != "pessoa_juridica" && chave != "pessoa_fisica"
      chave
      else
      'tipo_pessoa'
      end
      } = ? "}.join(' or   ')})"
      parametro_para_sql << lista_check_box
      busca["tipo"].collect do |chave,campo|
        if chave != "pessoa_juridica" && chave != "pessoa_fisica"
          conteudo_para_sql << true
        else
          if chave == "pessoa_juridica"
            conteudo_para_sql << JURIDICA
          else
            conteudo_para_sql << FISICA
          end
        end
      end
    end

    unless busca["conteudo"].blank?
      parametro_para_sql << " (nome like ? or razao_social like ? or cpf like ? or contato like ? or cnpj like ?)"
      5.times do
        conteudo_para_sql << busca["conteudo"].formatar_para_like
      end
    end
    
    pessoas = paginate :all, :conditions =>[parametro_para_sql.join(" AND ")]+conteudo_para_sql, :order => 'nome', :page => page, :per_page => 50
    if pessoas.reject{|pessoa| pessoa.spc == false}.length > 0
      inclui_legenda = true
    else
      inclui_legenda = false
    end
    [pessoas, inclui_legenda]
  end

  def fisica?
    tipo_pessoa == FISICA
  end

  def juridica?
    tipo_pessoa == JURIDICA
  end

  def self.retorna_cpf_cnpj_encontrado(params)
    documento = nil
    if params[:tipo_de_documento] == "cpf" 
      documento = Cpf.new params[:documento]
    else
      documento = Cnpj.new params[:documento]
    end

    unless documento.numero.blank?
      @pessoas = Pessoa.all :conditions=>["(cpf = ?) or (cnpj = ?)",documento.numero,documento.numero]
      @pessoas.reject!{|pessoa| pessoa.id == params[:id].to_i} unless params[:id].blank?
    end
    return @pessoas
  end

  def categorias
    categoria = []
    categoria << "Funcionário" if funcionario
    categoria << "Cliente" if cliente
    categoria << "Fornecedor" if fornecedor
    categoria.compact.join(' / ')
  end

  def dias_em_atraso
    array_parc = []
    contratos = RecebimentoDeConta.find(:all,:include=>[:unidade], :conditions => ['unidades.unidade_mae_id IS NULL AND pessoa_id = ?', self.id])

    contratos.each do |item|
      item.parcelas.each do |parc|
        if Date.today.to_date > parc.data_vencimento.to_date && parc.verifica_situacoes
          array_parc << parc.data_vencimento.to_date
        end
      end
    end
    if array_parc.blank?
      0
    else
      atraso = (Date.today.to_datetime) - ((array_parc.min).to_datetime)
      atraso
    end
  end

  def tem_parcelas_atrasadas?
    #!RecebimentoDeConta.find_all_by_pessoa_id(self.id).collect(&:resumo_de_parcelas_atrasadas).to_s.empty?
    !RecebimentoDeConta.all(:include=>[:unidade],:conditions=>["unidades.unidade_mae_id IS NULL AND pessoa_id = ?",self.id]).collect(&:resumo_de_parcelas_atrasadas).to_s.empty?
  end

  def unidade_parcelas_atrasadas
    unidades = []
    RecebimentoDeConta.find_all_by_pessoa_id(self.id).each do |conta|
      if !conta.resumo_de_parcelas_atrasadas.blank?
        unidades << conta.unidade.nome if !unidades.include?(conta.unidade.nome) && conta.unidade.unidade_mae_id.blank?
      end
    end

    if unidades.length > 1
      ultimo_unidade = unidades.delete_at(unidades.size-1)
      mensagem = "nas unidades #{unidades.join()} e #{ultimo_unidade}"
    else
      mensagem = "na unidade #{unidades[0]}"
    end
    mensagem
  end

  def self.importar_clientes(file, unidade_id)
    total_salvos = 0
    total_n_salvos = 0
    unidade = Unidade.find(unidade_id)
    file = file.read
    return false if file.blank?
    file = Hash.from_xml(file)
    registros = Pessoa.verifica_e_retorna_valor_do_hash(file,["workbook", "worksheet", "table", "row"])
    return false unless registros
    log_name = "importacao_#{DateTime.now.strftime("%d-%m-%Y_%H-%M-%S")}.log"
    Dir.mkdir(RAILS_ROOT+"/tmp/log_importacao_clientes") unless File.exists?(RAILS_ROOT+"/tmp/log_importacao_clientes")
    log = nil
    registros[2..-1].each_with_index do |row, n_row|
      pessoa = Pessoa.new
      pessoa.cliente = true
      pessoa.unidade_id = unidade.id
      pessoa.entidade_id = unidade.entidade.id
      if row.has_key?("cell")
        row["cell"].each_with_index do |cell, index|
          pessoa.send("importa_#{CAMPOS_PARA_IMPORTACAO[index]}", cell["data"]) unless cell["data"].is_a?(Hash)
        end
        unless pessoa.save
          if log.blank?
            log = Logger.new(RAILS_ROOT+"/tmp/log_importacao_clientes/#{log_name}")
          end
          log.error("#{DateTime.now.strftime("%d-%m-%Y_%H:%M:%S")} :: Registro Linha #{n_row+3} contem os seguintes Erros:")
          pessoa.errors.full_messages.each do |mensagem_erro|
            log.error("\t #{mensagem_erro}")
          end
          total_n_salvos += 1
        else
          total_salvos += 1
        end
      end
    end
    return [total_salvos, total_n_salvos]
  end

  def self.verifica_e_retorna_valor_do_hash(hash, chaves)
    chaves.each do |chave|
      if hash.is_a?(Hash)
        if hash.has_key?(chave)
          hash = hash[chave]
        else
          return false
        end
      else
        return false
      end
    end
    return hash
  end

  def importa_cpf_cnpj(value)
    unless value.blank?
      if Cpf.new(value).valido?
        self.cpf = value
        self.tipo_pessoa = "1"
      elsif Cnpj.new(value).valido?
        self.cnpj = value
        self.tipo_pessoa = "2"
      end
    end
  end

  def importa_nome(value)
    unless value.blank?
      if self.fisica?
        self.nome = value.gsub("'"," ")
      elsif self.juridica?
        self.razao_social = value.gsub("'"," ")
      end
    end
  end

  def importa_endereco(value)
    unless value.blank?
      self.endereco = value.gsub("'"," ")
    end
  end

  def importa_bairro(value)
    unless value.blank?
      self.bairro = value.gsub("'"," ")
    end
  end

  def importa_cidade(value)
    unless value.blank?
      self.cidade = value.gsub("'"," ")
    end
  end

  def importa_uf(value)
    if !value.blank? && !self.cidade.blank?
      localidade = Localidade.find(:first, :conditions =>"(nome LIKE '%#{self.cidade}%') AND (uf LIKE '#{value.gsub("'"," ")}')")
      unless localidade.blank?
        self.localidade_id = localidade.id
      end
    end
  end

  def importa_cep(value)
    unless value.blank?
      self.cep = value.gsub("'"," ")
    end
  end

  def importa_fone(value)
    unless value.blank?
      if self.telefone.blank?
        self.telefone = [value.gsub("'"," ")]
      else
        self.telefone << value.gsub("'"," ")
      end
    end
  end

  def busca_usuario_unidade(unidade_id)
    retorno = self.usuarios.find_by_unidade_id(unidade_id)
    retorno.blank? ? false : true
  end
  
  def self.pesquisa_clientes_liberados(unidade_id)
    Pessoa.find(:all, :conditions => ['unidade_id = ? AND cliente = ? AND liberado_pelo_dr = ?', unidade_id, true, true])
  end

end
