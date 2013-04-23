require File.dirname(__FILE__) + '/../spec_helper'

describe ImpostosController do
  
  integrate_views
   
  it 'should get index' do
    login_as :juliano
    get :index
    response.should be_success
    response.should render_template('index')
    response.should have_tag('table.listagem') do
      with_tag('tr[class=?]','impar') do
        with_tag('td') do
          with_tag('a[href=?]','/impostos/834097239', 'INSS-PF-3.6%')
        end
        with_tag('td','3.6')
        with_tag('td','Estadual')
        with_tag('td','Retém')
        with_tag('td[class=?]','ultima_coluna') do
          with_tag('a[href=?]','/impostos/834097239/edit')
          with_tag('a[href=?][onclick*=?]','/impostos/834097239','exclusão')
        end
      end
      with_tag('tr[class=?]','par') do
        with_tag('td') do
        end
        with_tag('td','IPI-PF-50%')
        with_tag('td','Estadual')
        with_tag('td','Retém')
      end
    end
  end

  it "should get show" do
    login_as :quentin
    imposto = impostos(:iss)
    get :show, :id => imposto.id
    response.should be_success
    response.should render_template('show')
    assigns[:imposto].id.should == imposto.id
  end

  it 'should get new' do
    login_as :juliano
    get :new
    response.should be_success
    response.should render_template('new')
    response.should have_tag('form[action=?][class=?][id=?][method=?]', impostos_path,'new_imposto','new_imposto','post') do
      validar_campos_form
    end
  end
  
  it 'should get edit' do
    login_as :quentin
    imposto = impostos(:iss)
    get :edit, :id => imposto.id
    response.should be_success
    response.should render_template('edit')
    response.should have_tag('form[action=?]', imposto_path(imposto.id)) do
      validar_campos_form
    end
  end

  def validar_campos_form
    response.should have_tag('table') do
      response.should have_tag('tr') do
        with_tag('td[class=?]','field_descriptor','Descrição')
        with_tag('td') do
          with_tag('input[id=?][name=?]','imposto_descricao','imposto[descricao]')
        end
      end
      response.should have_tag('tr') do
        with_tag('td[class=?]','field_descriptor','Sigla')
        with_tag('td') do
          with_tag('input[id=?][name=?]','imposto_sigla','imposto[sigla]')
        end
      end
      response.should have_tag('tr') do
        with_tag('td[class=?]','field_descriptor','Alíquota')
        with_tag('td') do
          with_tag('input[id=?][name=?]','imposto_aliquota','imposto[aliquota]')
        end
      end
      response.should have_tag('tr') do
        with_tag('th[class=?]','field_descriptor','Tipo')
        with_tag('td') do
          with_tag('select[id=?][name=?]','imposto_tipo','imposto[tipo]') do
            with_tag('option[value=?]','')
            with_tag('option[value=?]','0','Municipal')
            with_tag('option[value=?]','1','Estadual')
            with_tag('option[value=?]','2','Federal')
          end
        end
      end
      response.should have_tag('tr') do
        with_tag('th[class=?]','field_descriptor','Classificação')
        with_tag('td') do
          with_tag('select[id=?][name=?][onchange*=?]', 'imposto_classificacao', 'imposto[classificacao]', "if ($('imposto_classificacao').value == '') {") do
            with_tag('option[value=?]','')
            with_tag('option[value=?]','0','Incide')
            with_tag('option[value=?]','1','Retém')
          end
        end
      end
      response.should have_tag('tr') do
        with_tag('th[class=?]','field_descriptor','Conta Débito')
        with_tag('td') do
          with_tag('input[id=?][name=?][type=?]','imposto_conta_debito_id','imposto[conta_debito_id]','hidden')
          with_tag('input[id=?][name=?]','imposto_nome_conta_debito','imposto[nome_conta_debito]')
          with_tag('div[id=?][class=?]','imposto_nome_conta_debito_auto_complete','auto_complete_para_conta')
          with_tag('script[type=?]','text/javascript')
          with_tag('img[alt=?][id=?]','Loading','loading_conta_debito')
        end
      end
      response.should have_tag('tr') do
        with_tag('th[class=?]','field_descriptor','Conta Crédito')
        with_tag('td') do
          with_tag('input[id=?][name=?][type=?]','imposto_conta_credito_id','imposto[conta_credito_id]','hidden')
          with_tag('input[id=?][name=?]','imposto_nome_conta_credito','imposto[nome_conta_credito]')
          with_tag('div[id=?][class=?]','imposto_nome_conta_credito_auto_complete','auto_complete_para_conta')
          with_tag('script[type=?]','text/javascript')
          with_tag('img[alt=?][id=?]','Loading','loading_conta_debito')
        end
      end
      response.should have_tag('tr') do
        with_tag('td') do
          with_tag('input[id=?][name=?][type=?][value=?]','imposto_submit','commit','submit','Salvar')
        end
      end
    end
  end

  it 'should create valid object' do
    login_as :juliano
    post :create, :imposto => {:entidade=>entidades(:sesi),:descricao=>'teste',:sigla=>'teste',:aliquota=>'2,1', :tipo=>'1',:classificacao=>'1',:conta_debito=>plano_de_contas(:plano_de_contas_ativo_contribuicoes),:conta_credito=>plano_de_contas(:plano_de_contas_ativo_despesas)}
    response.should redirect_to(impostos_path)
  end
  
  it 'should not create invalid object' do
    login_as :juliano
    post :create, :imposto => {:entidade=>entidades(:sesi),:descricao=>'',:sigla=>'', :aliquota=>'', :tipo=>'',:classificacao=>'',:conta_debito_id=>'',:conta_credito_id=>''}
    response.should render_template('new')
  end

  it 'should update valid object' do
    login_as :quentin
    imposto = impostos(:iss)
    put :update, :id => imposto.id, :imposto => {'aliquota'=>imposto.aliquota.real.to_s}
    assigns(:imposto).should == Imposto.find(imposto.id)
    response.should redirect_to(impostos_path)
  end

  it 'should not update invalid object' do
    login_as :quentin
    imposto = impostos(:iss)
    put :update, :id => imposto.id, :imposto => {:tipo=>'', :aliquota => ''}
    assigns(:imposto).should == Imposto.find(imposto.id)
    response.should render_template('edit')
  end

  it 'should delete object' do
    login_as :quentin
    lambda {
      delete :destroy, :id => impostos(:iss).id
    }.should change(Imposto, :count).by(-1)
    response.should redirect_to(impostos_path)
  end
  
  it "bloqueia usuario juvenal que não tem acesso a action new do model Impostos" do
    login_as :juvenal
    get :new 
    response.should redirect_to(login_path)
  end
  
  it "bloqueia usuario juvenal que não tem acesso a action edit do model Impostos" do
    login_as :juvenal
    imposto = impostos(:iss)
    get :edit , :id=>imposto.id
    response.should redirect_to(login_path)
  end
  
  it "bloqueia usuario juvenal que não tem acesso a action destroy do model Impostos" do
    login_as :juvenal
    imposto = impostos(:iss)
    delete :destroy , :id=>imposto.id
    response.should redirect_to(login_path)
  end

  describe "Teste de bloqueio das actions caso o imposto não seja da Entidade logada" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      @imposto = impostos(:iss)
    end

    after do
      assigns[:imposto].should == @imposto
      response.should redirect_to(login_path)
    end

    [:update, :destroy].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @imposto
      end
    end

  end
  
end