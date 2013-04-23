# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe Usuario do

  describe 'being created' do
    
    before do
      @usuario = nil
      @creating_usuario = lambda do
        @usuario = create_usuario
        violated "#{@usuario.errors.full_messages.to_sentence}" if @usuario.new_record?
      end
    end

    it 'increments Usuario#count' do
      @creating_usuario.should change(Usuario, :count).by(1)
    end
  end

  #
  # Validations
  #

  it 'requires login' do
    lambda do
      u = create_usuario(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(Usuario, :count)
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
      'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_usuario(:login => login_str)
          u.errors.on(:login).should     be_nil
        end.should change(Usuario, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate logins:' do
    ['12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
      "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
      'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space '].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_usuario(:login => login_str)
          u.errors.on(:login).should_not be_nil
        end.should_not change(Usuario, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_usuario(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(Usuario, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_usuario(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(Usuario, :count)
  end

  it 'resets password' do
    usuarios(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Usuario.authenticate('quentin', 'new password').should == usuarios(:quentin)
  end

  it 'does not rehash password' do
    usuarios(:quentin).update_attributes(:login => 'quentin2')
    Usuario.authenticate('quentin2', 'monkey').should == usuarios(:quentin)
  end

  #
  # Authentication
  #

  it 'authenticates usuario' do
    Usuario.authenticate('quentin', 'monkey').should == usuarios(:quentin)
  end

  it 'authenticates usuario que possui pessoa inativa' do
    pessoa_do_quentin = pessoas(:felipe)
    pessoa_do_quentin.funcionario_ativo = false
    pessoa_do_quentin.save.should == true

    Usuario.authenticate('quentin', 'monkey').should == nil
  end

  it "doesn't authenticate usuario with bad password" do
    Usuario.authenticate('quentin', 'invalid_password').should be_nil
  end

  if REST_AUTH_SITE_KEY.blank?
    # old-school passwords
    it "authenticates a user against a hard-coded old-style password" do
      Usuario.authenticate('old_password_holder', 'test').should == usuarios(:old_password_holder)
    end
  else
    it "doesn't authenticate a user against a hard-coded old-style password" do
      Usuario.authenticate('old_password_holder', 'test').should be_nil
    end

    # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
    desired_encryption_expensiveness_ms = 0.1
    it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
      test_reps = 100
      start_time = Time.now; test_reps.times{ Usuario.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
      auth_time_ms = 1000 * (end_time - start_time)/test_reps
      auth_time_ms.should > desired_encryption_expensiveness_ms
    end
  end

  #
  # Authentication
  #

  it 'sets remember token' do
    usuarios(:quentin).remember_me
    usuarios(:quentin).remember_token.should_not be_nil
    usuarios(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    usuarios(:quentin).remember_me
    usuarios(:quentin).remember_token.should_not be_nil
    usuarios(:quentin).forget_me
    usuarios(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    usuarios(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    usuarios(:quentin).remember_token.should_not be_nil
    usuarios(:quentin).remember_token_expires_at.should_not be_nil
    usuarios(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    usuarios(:quentin).remember_me_until time
    usuarios(:quentin).remember_token.should_not be_nil
    usuarios(:quentin).remember_token_expires_at.should_not be_nil
    usuarios(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    usuarios(:quentin).remember_me
    after = 2.weeks.from_now.utc
    usuarios(:quentin).remember_token.should_not be_nil
    usuarios(:quentin).remember_token_expires_at.should_not be_nil
    usuarios(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it "teste de relacionamentos" do
    usuarios(:quentin).unidade.should == unidades(:senaivarzeagrande)
    usuarios(:quentin).perfil.should == perfis(:master_main)
    usuarios(:quentin).funcionario.should == pessoas(:felipe)
    usuarios(:aaron).funcionario.should == pessoas(:juan)
  end
  
  it "teste de campos obrigatorios" do
    @usuario = Usuario.new :funcionario_id => pessoas(:felipe).id
    @usuario.should_not be_valid
    @usuario.errors.on(:unidade).should_not be_nil
    @usuario.errors.on(:perfil).should_not be_nil
    @usuario.unidade = unidades(:senaivarzeagrande)
    @usuario.perfil = perfis(:master_main)
    @usuario.valid?
    @usuario.errors.on(:unidade).should be_nil
    @usuario.errors.on(:perfil).should be_nil
  end

  it "teste do atributo virtual nome" do
    usuario = usuarios(:quentin)
    usuario.funcionario.should == pessoas(:felipe)
    usuario.nome.should == pessoas(:felipe).nome

    usuario_dois = usuarios(:aaron)
    usuario_dois.funcionario.should == pessoas(:juan)
    usuario_dois.nome.should == pessoas(:juan).nome
  end

  it "teste de preenchimento de pessoas que não é funcionario" do
    @usuario = Usuario.new :funcionario_id => pessoas(:paulo).id
    @usuario.login = "diabetes"
    @usuario.password = "testando"
    @usuario.password_confirmation = "testando"
    @usuario.unidade = unidades(:senaivarzeagrande)
    @usuario.perfil = perfis(:master_main)
    @usuario.save
    @usuario.should_not be_valid
    @usuario.errors.on(:funcionario).should == "está preenchido com uma pessoa que não é um funcionario."
  end

  it "um funcionario tem apenas um usuário cadastrado" do
    @usuario = usuarios(:quentin)
    @usuario_dois = Usuario.new :funcionario_id => pessoas(:felipe).id
    @usuario_dois.login = "testando"
    @usuario_dois.password = "testando"
    @usuario_dois.password_confirmation = "testando"
    @usuario_dois.unidade = unidades(:senaivarzeagrande)
    @usuario_dois.perfil = perfis(:master_main)
    @usuario_dois.save
    @usuario_dois.should_not be_valid
    @usuario_dois.errors.on(:funcionario_id).should == 'já está cadastrado em outro usuário!'
  end

  it "teste de validação do campo funcionario" do
    @usuario = Usuario.new :funcionario_id => nil
    @usuario.password = "testando"
    @usuario.password_confirmation = "testando"
    @usuario.unidade = unidades(:senaivarzeagrande)
    @usuario.perfil = perfis(:master_main)
    @usuario.save
    @usuario.errors.on(:funcionario).should == "deve ser preenchido."
  end

  it "teste de permissoes" do
    usuarios(:quentin).possui_permissao_para(Perfil::Agencias).should == true
    usuarios(:quentin).possui_permissao_para(Perfil::Bancos).should == true
    usuarios(:quentin).possui_permissao_para(Perfil::Entidades).should == true
    usuarios(:quentin).possui_permissao_para(Perfil::Historicos).should == true
    usuarios(:aaron).possui_permissao_para(Perfil::Unidades).should == nil
    usuarios(:aaron).possui_permissao_para(Perfil::ManipularDadosDasAgencias).should == true
    usuarios(:aaron).possui_permissao_para(Perfil::UnidadeOrganizacionais).should == nil
    usuarios(:aaron).possui_permissao_para(Perfil::Parcelas).should == true
    usuarios(:aaron).possui_permissao_para(Perfil::ManipularDadosDasParcelas).should == true
    usuarios(:juvenal).possui_permissao_para(Perfil::ManipularDadosDasParcelas).should == nil
    usuarios(:juvenal).possui_permissao_para(Perfil::ManipularDadosDosHistoricos).should == nil
    usuarios(:juvenal).possui_permissao_para(Perfil::ManipularDadosDosUsuarios).should == nil
    usuarios(:juvenal).possui_permissao_para(Perfil::ManipularDadosDasAgencias).should == nil
    usuarios(:juvenal).possui_permissao_para(Perfil::UnidadeOrganizacionais).should == nil
    usuarios(:juvenal).possui_permissao_para_um_item(Perfil::Pessoas).should == false
    usuarios(:juvenal).possui_permissao_para_um_item(Perfil::Pessoas, Perfil::Usuarios).should == false
    usuarios(:juvenal).possui_permissao_para_um_item(Perfil::Pessoas, Perfil::Unidades).should == false
    usuarios(:juvenal).possui_permissao_para_um_item(Perfil::Pessoas, Perfil::Relatorios).should == true
  end
  

  
  protected
  
  def create_usuario(options = {})
    funcionario = Pessoa.new :nome => "Carlos", :cpf => "723.455.906-02", :funcionario => true,
      :endereco => "Av. das Torres", :bairro => "Jardim das Américas", :tipo_pessoa => Pessoa::FISICA,
      :telefone => ["3090-9090"], :entidade_id => entidades(:senai).id, :unidade_id => unidades(:senaivarzeagrande).id
    funcionario.save!
    record = Usuario.new({ :login => 'quire', :password => 'quire69', :password_confirmation => 'quire69', :perfil_id => perfis(:master_main).id, :funcionario_id => funcionario.id }.merge(options))
    record.unidade = unidades(:senaivarzeagrande)
    record.save
    record
  end
  
end
