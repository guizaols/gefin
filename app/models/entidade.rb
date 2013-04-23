class Entidade < ActiveRecord::Base

  acts_as_audited
  
  #VALIDAÇÕES
  validates_presence_of :nome, :message => "deve ser preenchido."
  validates_presence_of :sigla, :message =>"deve ser preenchido."
  validates_presence_of :codigo_zeus, :message => "deve ser preenchido."
  validates_uniqueness_of :codigo_zeus, :message => "já foi cadastrado no sistema."

  #RELACIONAMENTOS 
  has_many :unidades
  has_many :centros
  has_many :impostos
  has_many :pessoas
  has_many :agencias
  has_many :historicos
  has_many :unidade_organizacionais
  has_many :plano_de_contas

  #CONSTANTES
  HUMANIZED_ATTRIBUTES = {
    :nome => 'O campo nome',
    :sigla =>'O campo sigla',
    :codigo_zeus =>'O campo código zeus',
  }
  
  def self.importar_dados_do_gefin(arquivo_localidade ="#{RAILS_ROOT}/lib/cidades_original.sql",arquivo_entidade="#{RAILS_ROOT}/lib/entidades_modificado.sql",arquivo_plano_de_contas="#{RAILS_ROOT}/lib/plano_de_contas.sql",arquivo_unidade_organizacional = "#{RAILS_ROOT}/lib/undorg.sql",arquivo_centro="#{RAILS_ROOT}/lib/centro.sql")
    Iconv.conv('UTF-8', 'ISO-8859-15', File.read(arquivo_localidade)).each { |linha| (Localidade.create :nome => $1, :uf => $2) if linha.match %r{\t(.*)\t(..)\n}  }
    Iconv.conv('UTF-8', 'ISO-8859-15', File.read(arquivo_entidade)).each { |linha| (Entidade.create :nome => $1, :sigla => $2, :codigo_zeus=>$3) if linha.match %r{^.*\t(.*)\t(.*)\t(.*).*\n}  }
    hash_entidades = {}
    Entidade.all.each{|entidade|  hash_entidades[entidade.codigo_zeus.to_s]= entidade.id  }
    Iconv.conv('UTF-8', 'ISO-8859-15', File.read(arquivo_plano_de_contas)).each { |linha| (PlanoDeConta.create :ano => $1,:entidade_id=>hash_entidades[$2.to_s],:codigo_contabil=>$3,:nome=>$4,:nivel=>$5,:ativo=>$6,:tipo_da_conta=>$7,:codigo_reduzido=>$8) if linha.match %r{^(.*)\t(.*)\t(.*)\t(.*)\t.*\t.*\t(.*)\t(.*)\t(.*)\t(.*)\t.*\t.*\n}  }
    Iconv.conv('UTF-8', 'ISO-8859-15', File.read(arquivo_unidade_organizacional)).each { |linha| (UnidadeOrganizacional.create :ano => $1, :entidade_id =>hash_entidades[$2.to_s], :codigo_da_unidade_organizacional=>$3,:nome=>$4,:codigo_reduzido=>$5) if linha.match %r{^(.*)\t(.*)\t(.*)\t(.*)\t(.*)     \t.*\t.*\n}  }
    Iconv.conv('UTF-8', 'ISO-8859-15', File.read(arquivo_centro)).each { |linha| (Centro.create :ano => $1, :entidade_id =>hash_entidades[$2.to_s], :codigo_centro=>$3,:nome=>$4,:codigo_reduzido=>$5) if linha.match %r{^(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t.*\n} }
  end

  def self.importar_localidades_do_gefin(arquivo_localidade ="#{RAILS_ROOT}/lib/cidades_original.sql")
    Iconv.conv('UTF-8', 'ISO-8859-15', File.read(arquivo_localidade)).each { |linha| (Localidade.create :nome => $1, :uf => $2) if linha.match %r{\t(.*)\t(..)\n}  }
  end

  def self.retorna_entidades_para_select(entidade_corrente_id)
    Entidade.all(:order => 'nome ASC').collect{|entidade| [entidade.sigla, entidade.id] if entidade.id != entidade_corrente_id}.reject!(&:blank?)
  end

end