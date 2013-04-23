require File.dirname(__FILE__) + '/../spec_helper'

describe DependentesController do
  integrate_views

  before do
    login_as 'quentin'
  end

  it "teste action new" do
    pessoa = pessoas(:paulo)
    get :new,:pessoa_id => pessoa.id
    response.should be_success
  end

  it "Testando se esta criando um dependente Novo" do
    pessoa = pessoas(:paulo)
    dependente = mock_model(Dependente,:id=>'1',:nome=>"Joao",:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga",:pessoa_id=>pessoa.id,:data_de_nascimento=>"2000-01-01")
    Dependente.should_receive(:new).with('nome' => 'Joao','nome_do_pai'=>'Ananias','nome_da_mae'=>'Moranga').and_return dependente
    dependente.should_receive(:pessoa_id=).with("#{pessoa.id}")
    dependente.should_receive(:save).and_return true
    post :create, :dependente => {:nome=>"Joao",:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga"},:pessoa_id =>pessoa.id
    assigns[:dependente].should == dependente
    response.should redirect_to(pessoa_path(pessoa.id))
  end


  it"nao cria dependente" do
    pessoa = pessoas(:paulo)
    dependente = mock_model(Dependente,:id=>'1',:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga",:pessoa_id=>pessoa.id,:data_de_nascimento=>"2000-01-01")
    Dependente.should_receive(:new).with('nome_do_pai'=>'Ananias','nome_da_mae'=>'Moranga').and_return dependente
    dependente.should_receive(:pessoa_id=).with("#{pessoa.id}")
    dependente.should_receive(:save).and_return true
    post :create, :dependente => {:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga"},:pessoa_id =>pessoa.id
    assigns[:dependente].should == dependente
    response.should redirect_to(pessoa_path(pessoa.id))
  end

  it "Testando se existe a action edit" do
    pessoa = pessoas(:paulo)
    dependente = mock_model(Dependente,:id=>'1',:nome=>'Paulo',:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga",:pessoa_id=>pessoa.id,:data_de_nascimento=>"2000-01-01")
    Dependente.should_receive(:find_by_id_and_pessoa_id).with('1',"#{pessoa.id}").and_return dependente
    get :edit, :id => '1',:pessoa_id => "#{pessoa.id}"
    response.should render_template('edit')
  end

  it "Testando se existe a action show" do
    pessoa = pessoas(:paulo)
    dependente = mock_model(Dependente,:id=>'1',:nome=>'Paulo',:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga",:pessoa_id=>pessoa.id,:data_de_nascimento=>"2000-01-01")
    Dependente.should_receive(:find_by_id_and_pessoa_id).with('1',"#{pessoa.id}").and_return dependente
    get :show, :id => '1',:pessoa_id => "#{pessoa.id}"
    response.should render_template('show')
  end

  it "Fazendo o update" do
    pessoa = pessoas(:paulo)
    dependente = mock_model(Dependente,:id=>'1',:nome=>'Paulo',:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga",:pessoa_id=>pessoa.id,:data_de_nascimento=>"2000-01-01")
    Dependente.should_receive(:find_by_id_and_pessoa_id).with('1',"#{pessoa.id}").and_return dependente
    dependente.should_receive(:update_attributes).with('nome' => 'teste').and_return true
    put :update, :id=>'1', :dependente => {:nome=>'teste'},:pessoa_id=>"#{pessoa.id}"
    response.should redirect_to(pessoa_path(pessoa.id))
  end

  it "nao conseguiu fazer o update" do
    pessoa = pessoas(:paulo)
    dependente = mock_model(Dependente,:id=>'1',:nome=>'Paulo',:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga",:pessoa_id=>pessoa.id,:data_de_nascimento=>"2000-01-01")
    Dependente.should_receive(:find_by_id_and_pessoa_id).with('1',"#{pessoa.id}").and_return dependente
    dependente.should_receive(:update_attributes).with('nome' => '').and_return false
    put :update, :id=>'1', :dependente => {:nome=>''},:pessoa_id=>"#{pessoa.id}"
    response.should render_template('edit')
  end

  it"Testando se existe a action Destroy" do
    pessoa = pessoas(:paulo)
    dependente = mock_model(Dependente,:id=>'1',:nome=>'Paulo',:nome_do_pai=>"Ananias",:nome_da_mae=>"Moranga",:pessoa_id=>pessoa.id,:data_de_nascimento=>"2000-01-01")
    Dependente.should_receive(:find_by_id_and_pessoa_id).with('1',"#{pessoa.id}").and_return dependente
    dependente.should_receive(:destroy)
    delete :destroy, :id => '1',:pessoa_id => "#{pessoa.id}"
    response.should redirect_to(pessoa_path(pessoa.id))
  end


end