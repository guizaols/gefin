class ParametroContaValor < ActiveRecord::Base

  acts_as_audited

  validates_presence_of :unidade, :message => 'deve ser preenchido.'
  validates_presence_of :conta_contabil, :message => 'deve ser preenchida.'
  validates_presence_of :tipo, :message => 'deve ser preenchido.'
  validates_presence_of :ano, :message => 'deve ser preenchido.'
  validates_uniqueness_of :tipo, :scope => [:unidade_id,:ano],:message => 'já está em uso para essa unidade.'
  belongs_to :unidade
  belongs_to :conta_contabil,:class_name=>'PlanoDeConta',:foreign_key=>"conta_contabil_id"
  attr_protected :unidade_id, :ano
  cria_readers_e_writers_para_o_nome_dos_atributos :conta_contabil
  
  HUMANIZED_ATTRIBUTES = {
    :tipo =>'O campo tipo',
    :conta_contabil => 'O campo da conta contábil',
    :unidade_id => 'O campo unidade',
    :ano =>'O campo ano',
  }
  
  JUROS_MULTA = 0
  TAXA_DE_BOLETO = 1
  DESCONTO_PF = 2
  DESCONTO_PJ = 3
  OUTROS_DEBITOS = 4
  OUTROS_CREDITOS = 5
  FORNECEDOR = 6
  CHEQUE_PRE_DATADO = 7
  CLIENTES = 8
  FATURAMENTO = 9
  JUROS_E_MULTAS_DE_CONTRATOS_RENEGOCIADOS = 10
  PARAMETRO_VISACREDITO = 11
  PARAMETRO_REDECARD = 12
  PARAMETRO_MASTERCARD = 13
  PARAMETRO_DINERS = 14
  PARAMETRO_AMERICANEXPRESS = 15
  PARAMETRO_MAESTRO = 16
  PARAMETRO_CREDICARD = 17
  PARAMETRO_OUROCARD = 18
  PARAMETRO_VISADEBITO = 19


  TIPOS_DE_PARAMETROS = [JUROS_MULTA, TAXA_DE_BOLETO, DESCONTO_PF, DESCONTO_PJ, OUTROS_DEBITOS, OUTROS_CREDITOS,
    FORNECEDOR, CHEQUE_PRE_DATADO, CLIENTES, FATURAMENTO,  JUROS_E_MULTAS_DE_CONTRATOS_RENEGOCIADOS,
    PARAMETRO_VISACREDITO, PARAMETRO_REDECARD, PARAMETRO_MASTERCARD, PARAMETRO_DINERS,
    PARAMETRO_AMERICANEXPRESS, PARAMETRO_MAESTRO, PARAMETRO_CREDICARD, PARAMETRO_OUROCARD,
    PARAMETRO_VISADEBITO]
  TIPOS_DE_PARAMETROS_VERBOSE = ['Juros/Multa', 'Taxa de Boleto', 'Desconto PF', 'Desconto PJ', 'Outros (Débitos)',
    'Outros (Crédito)','Fornecedor','Cheque Pré-Datado', 'Clientes', 'Faturamento',
    'Juros e Multas de Contratos Renegociados', 'Visa Crédito', 'Redecard', 'Mastercard',
    'Diners', 'American Express', 'Maestro', 'Credicard', 'Ourocard', 'Visa Débito']


  def tipo_de_parametro_verbose
    TIPOS_DE_PARAMETROS_VERBOSE[tipo] rescue ''
  end
  
  def validate
    errors.add :conta_contabil, "deve ser analítica." if (self.conta_contabil) && (self.conta_contabil.tipo_da_conta == 0)
  end

  def self.retorna_tipos_de_parametro
    return [['American Express', PARAMETRO_AMERICANEXPRESS], ['Cheque Pré-Datado', CHEQUE_PRE_DATADO],
      ['Clientes', CLIENTES], ['Desconto PF', DESCONTO_PF], ['Desconto PJ', DESCONTO_PJ],
      ['Faturamento', FATURAMENTO], ['Fornecedor', FORNECEDOR], ['Juros/Multa', JUROS_MULTA],
      ['Juros e Multas de Contratos Renegociados', JUROS_E_MULTAS_DE_CONTRATOS_RENEGOCIADOS],
      ['Maestro', PARAMETRO_MAESTRO], ['Mastercard', PARAMETRO_MASTERCARD],
      ['Redecard', PARAMETRO_REDECARD], ['Taxa de Boleto', TAXA_DE_BOLETO],
      ['Visa Crédito', PARAMETRO_VISACREDITO], ['Visa Débito', PARAMETRO_VISADEBITO]]
  end

end
