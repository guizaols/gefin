require 'digest/sha1'

class Usuario < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  acts_as_audited :protect => false

  INATIVO = 0
  ATIVO = 1

  validates_presence_of     :login,    :message => 'deve ser preenchido.'
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD

  attr_accessible :login, :password, :password_confirmation, :perfil_id, :funcionario_id, :entidade_id
  validates_presence_of :unidade, :message => 'é inválida'
  validates_presence_of  :perfil, :funcionario, :message => 'deve ser preenchido.'
  #validates_uniqueness_of :funcionario_id, :allow_blank => true , :message => 'já está cadastrado em outro usuário!'
  belongs_to :entidade
  belongs_to :unidade
  belongs_to :perfil
  belongs_to :funcionario, :class_name => "Pessoa", :foreign_key => "funcionario_id"
  attr_accessor :nome, :mensagem_de_erro
  has_many :recebimento_de_contas
  has_many :reajustes

  HUMANIZED_ATTRIBUTES = {
    :password => 'O campo senha',
    :password_confirmation => 'O campo confirmação de senha',
    :unidade_id => 'O campo unidade',
    :perfil_id => 'O campo perfil',
    :funcionario_id => 'O campo funcionario',
    :entidade_id => 'O campo entidade'
  }

  def validate
    errors.add :funcionario, "está preenchido com uma pessoa que não é um funcionario." if self.funcionario && self.funcionario.funcionario != true
  end

  def self.authenticate(login, password)
    u = find(:first, :include => :funcionario, :conditions => ['usuarios.login = ? AND (pessoas.funcionario = ? AND pessoas.funcionario_ativo = ?)', login, true, true])
    u && u.authenticated?(password) ? u : nil
  end

  def possui_permissao_para(acao)
    true if self.perfil.permissao[acao].chr == 'S'
  end
  
  def possui_permissao_para_um_item(*acoes)
    acoes.any? {|acao| possui_permissao_para acao }
  end

  def nome
    self.funcionario.nome
  end

	def before_destroy
    if possui_algum_vinculo? || self.status == ATIVO
      self.mensagem_de_erro = "Não foi possível excluir o usuário #{self.login}, pois ele possui dados vinculados a si."
      return false
    end
  end

  def possui_algum_vinculo?
    conta_a_receber = []
    audit = []
    conta_a_pagar = PagamentoDeConta.find_all_by_pessoa_id(self.funcionario)
    conta_a_receber << (RecebimentoDeConta.first(:conditions => ["pessoa_id = ? or vendedor_id = ? or cobrador_id = ?", self.funcionario.id, self.funcionario.id, self.funcionario.id]))
    audit << Audit.first(:conditions => ['user_id = ?', self.id])
    (conta_a_pagar + conta_a_receber + audit).blank? ? false : true
  end

  def apenas_um_usuario_ativo(unidade_corrente_id)
    status_dos_usuarios = self.funcionario.usuarios.collect{|user| user.status if user.unidade_id != unidade_corrente_id.to_i}
    resultado = status_dos_usuarios.include?(ATIVO) ? true : false

    if resultado
      usuario = self.funcionario.usuarios.find_by_status(ATIVO)
      [true, "O funcionário #{self.funcionario.nome.upcase} possui um usuário ativo na unidade #{usuario.unidade.nome.upcase} com o seguinte login: #{usuario.login}"]
    else
      [false, 'Usuario cadastrado com sucesso!']
    end
  end

  def ativar_inativar_usuario(params, unidade_corrente_id)
    if params == 'ativar'
      retorno = self.apenas_um_usuario_ativo(unidade_corrente_id)
      if retorno.first
        usuario = self.funcionario.usuarios.find_by_status(ATIVO)
        [false,  "O funcionário #{self.funcionario.nome.upcase} possui um usuário ativo na unidade #{usuario.unidade.nome.upcase} com o seguinte login: #{usuario.login}"]
      else
        self.status = ATIVO
        self.save!
        [true, 'Usuário ativado com sucesso!']
      end
    elsif params == 'inativar'
      self.status = INATIVO
      self.save false
      [true, 'Usuário inativado com sucesso!']
    end
  end

end
