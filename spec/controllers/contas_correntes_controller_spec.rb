require File.dirname(__FILE__) + '/../spec_helper'

describe ContasCorrentesController do

  integrate_views

  it 'should get index' do
    login_as :quentin

    get :index
    response.should be_success
    response.should render_template('index')
    assigns[:contas_correntes].sort_by(&:id).should == contas_correntes(:primeira_conta, :conta_caixa, :conta_vazia).sort_by(&:id)
    
    response.should have_tag('table.listagem') do
      with_tag('td', %r{Conta do Senai Várzea Grande})
      with_tag('td', %r{Conta Caixa do Senai Várzea Grande})
    end
  end

  it "should get show" do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    get :show, :id => conta_corrente.id
    response.should be_success
    response.should render_template('show')
    assigns[:contas_corrente].id.should == conta_corrente.id
  end

  it 'não pode mostrar a show, unidade diferente' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    
    get :show, :id => conta_corrente.id
    response.should_not be_success
    response.should redirect_to(login_path)
  end

  it 'should get new' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    get :new
    response.should be_success
    response.should render_template('new')
    response.should have_tag('form[action=?]', contas_correntes_path) do
      validar_campos_form
    end
  end
  
  it 'should get edit' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    get :edit, :id => conta_corrente.id
    response.should be_success
    response.should render_template('edit')
    response.should have_tag('form[action=?]', contas_corrente_path(conta_corrente)) do
      with_tag 'input[name=_method][value=put]'
      validar_campos_form
    end
  end

  def validar_campos_form
    with_tag('input[name=?]', 'contas_corrente[descricao]')
    with_tag('input[name=?]', 'contas_corrente[numero_conta]')
    with_tag('input[name=?]', 'contas_corrente[digito_verificador]')
    with_tag("select[name='contas_corrente[identificador]']")
    with_tag('input[name=?]', 'contas_corrente[agencia_id]')
    with_tag('input[name=?]', 'contas_corrente[conta_contabil_id]')
    with_tag('input[name=?]', 'contas_corrente[tipo]')
    with_tag('input[name=?]', 'contas_corrente[data_abertura]')
    with_tag('input[name=?]', 'contas_corrente[data_encerramento]')
    #FELIPE: Comentei estes campos pois aparentemente o Gefin Delphi não faz nada com eles
#    with_tag('input[name=?]', 'contas_corrente[saldo_inicial_em_reais]')
#    with_tag('input[name=?]', 'contas_corrente[saldo_atual_em_reais]')
    with_tag("script",%r{'contas_corrente_data_abertura'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
    with_tag("script",%r{'contas_corrente_data_encerramento'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
  end

  it 'não pode mostrar a edit, unidade diferente' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    
    get :edit, :id => conta_corrente.id
    response.should_not be_success
    response.should redirect_to(login_path)
  end

  it 'should create valid object' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)    
    post :create, :contas_corrente => {:identificador => 1, :numero_conta => "2353", :digito_verificador => "9", :descricao => "Conta do Senai", :agencia => agencias(:centro), :conta_contabil => plano_de_contas(:plano_de_contas_ativo_contribuicoes),:saldo_inicial=>100,:saldo_atual=>200}
    response.should redirect_to(contas_correntes_path)
  end
  
  it 'should not create invalid object' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    post :create, :contas_corrente => {:numero_conta => "", :digito_verificador => "", :descricao => "", :agencia_id => ""}
    response.should render_template('new')
  end

  it 'should update valid object' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    put :update, :id => conta_corrente.id, :contas_corrente => {}
    assigns(:contas_corrente).should == ContasCorrente.find(conta_corrente)
    response.should redirect_to(contas_correntes_path)
  end

  it 'should not update invalid object' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    put :update, :id => conta_corrente.id, :contas_corrente => {:numero_conta => "", :digito_verificador => "", :descricao => "", :agencia_id => ""}
    assigns(:contas_corrente).should == ContasCorrente.find(conta_corrente)
    response.should render_template('edit')
  end

  it 'should delete object' do
    lambda {
      login_as :quentin
      conta_corrente = contas_correntes(:primeira_conta)
      delete :destroy, :id => conta_corrente.id
    }.should change(ContasCorrente, :count).by(-1)
    response.should redirect_to(contas_correntes_url)
  end

  it 'não pode mostrar a show, unidade diferente' do
    login_as :quentin
    conta_corrente = contas_correntes(:primeira_conta)
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    
    delete :destroy, :id => conta_corrente.id
    response.should_not be_success
    response.should redirect_to(login_path)
  end

  it "testa auto_complete de conta_correntes" do
    login_as :quentin
    post :auto_complete_for_conta_corrente, :argumento => 'a'
    response.should be_success
    assigns[:items].sort_by(&:id).should == contas_correntes(:primeira_conta, :conta_caixa, :conta_vazia).sort_by(&:id)

    response.should have_tag("ul") do
      with_tag("li[id=?]", contas_correntes(:primeira_conta).id, '2345-3 - Conta do Senai Várzea Grande')
      with_tag("li[id=?]", contas_correntes(:conta_caixa).id, 'Conta Caixa do Senai Várzea Grande')
    end
  end
  
  it "testa auto_complete de conta_correntes com termina_em" do
    login_as :quentin
    post :auto_complete_for_conta_corrente, :argumento => '*Conta'
    response.should be_success

    response.should have_tag("ul") do
      with_tag "li", false
    end
  end

  it "testa auto_complete_com_filtro_por_identificador de conta_correntes" do
    login_as :quentin
    post :auto_complete_for_conta_corrente_com_filtro_por_identificador, :argumento => 'a'
    response.should be_success
    assigns[:items].sort_by(&:id).should == contas_correntes(:primeira_conta, :conta_vazia).sort_by(&:id)

    response.should have_tag("ul") do
      with_tag("li[id=?]", contas_correntes(:primeira_conta).id, '2345-3 - Conta do Senai Várzea Grande')
      with_tag("li[id=?]", contas_correntes(:conta_vazia).id, '34445-1 - Conta Caixa - SENAI-VG')
    end
  end

  describe "Verifica se" do
    
    integrate_views
    
    it "bloqueia usuario que não tem permissao" do
      login_as :admin
      get :new
      response.should redirect_to(login_path)
    end
  
    it "libera usuario com acesso parcial" do
      login_as :aaron
      get :index
      response.should be_success
    end
    
  end
end