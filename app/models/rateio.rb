class Rateio < ActiveRecord::Base

  acts_as_audited

  #VALIDAÇÕES
  validates_presence_of :centro,:message => "deve ser preenchido."
  validates_presence_of :valor,:message => "deve ser preenchido."
  validates_presence_of :parcela, :message => "deve ser preenchido."
  validates_presence_of :unidade_organizacional, :message=>"deve ser preenchido"
  validates_presence_of :conta_contabil, :message => "deve ser preenchido"
  validates_numericality_of :valor,:greater_than=>0,:message=>"deve ser maior que zero."
  valida_anos_centro_e_unidade_organizacional :centro, :unidade_organizacional
  verifica_se_centro_pertence_a_unidade_organizacional :centro, :unidade_organizacional
  
  #RELACIONAMENTOS
  belongs_to :centro
  belongs_to :unidade_organizacional
  belongs_to :parcela
  belongs_to :conta_contabil,:class_name=>'PlanoDeConta',:foreign_key=>"conta_contabil_id"
  
  #CONSTANTES 
  HUMANIZED_ATTRIBUTES = {
    :centro => "O campo centro",
    :parcela => "O campo parcela",
    :conta_contabil => "O campo conta contábil",
    :unidade_organizacional => "O campo unidade organizacional",
    :valor => "O campo valor",
  }
  
  def retorna_itens_do_rateio_duplicados
    Rateio.find_all_by_parcela_id_and_unidade_organizacional_id_and_centro_id(self.parcela_id,self.unidade_organizacional_id,self.centro_id)
  end

  def ano
    self.parcela.try :ano
  end

  def unidade
    self.parcela.try :unidade
  end
  
end
