require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ConfiguracaoController do

  integrate_views
  
  
  it "Verifica se possui a action edit e se esta editando quando o usuario que possui permissao" do
    login_as :quentin
    get :edit
    response.should be_success
    response.should have_tag('p','Limite de dias para alteração de dados contábeis.')
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td') do
          with_tag('input[id=?][name=?][value=?]','unidade_lancamentoscontaspagar','unidade[lancamentoscontaspagar]','5000')
        end
      end
      with_tag('tr') do
        with_tag('td') do
          with_tag('input[id=?][name=?][value=?]','unidade_lancamentoscontasreceber','unidade[lancamentoscontasreceber]','5000')
        end
      end
      with_tag('tr') do
        with_tag('td') do
          with_tag('input[id=?][name=?][value=?]','unidade_lancamentosmovimentofinanceiro','unidade[lancamentosmovimentofinanceiro]','5000')
        end
      end
      with_tag('tr') do
        with_tag('td') do
          with_tag('input[id=?][name=?][type=?][value=?]','unidade_submit','commit','submit','Salvar')
          with_tag('a[href=?]',pessoas_path,'Voltar')
        end
      end
    end
  end

  it "Verifica se possui a action edit e se não esta editando quando o usuario não possui permissao" do
    login_as :admin
    get :edit
    response.should be_success
    response.should have_tag('p','Limite de dias para alteração de dados contábeis.')
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td') do
          with_tag('input[disabled=?][id=?][name=?][value=?]','disabled','unidade_lancamentoscontaspagar','unidade[lancamentoscontaspagar]','5000')
        end
      end
      with_tag('tr') do
        with_tag('td') do
          with_tag('input[disabled=?][id=?][name=?][value=?]','disabled','unidade_lancamentoscontasreceber','unidade[lancamentoscontasreceber]','5000')
        end
      end
      with_tag('tr') do
        with_tag('td') do
          with_tag('input[disabled=?][id=?][name=?][value=?]','disabled','unidade_lancamentosmovimentofinanceiro','unidade[lancamentosmovimentofinanceiro]','5000')
        end
      end
      with_tag('tr') do
        with_tag('td') do
          response.should_not have_tag('input[id=?][name=?][type=?][value=?]','unidade_submit','commit','submit','Salvar')
          with_tag('a[href=?]',pessoas_path,'Voltar')
        end
      end
    end
  end

  it "Verifica se possui a action update e se esta atualizando quando o usuario possui permissao" do
    login_as :quentin
    get :update
    response.should redirect_to(edit_configuracao_path)
  end

  it "Verifica se possui a action update e se não esta atualizando quando o usuario não possui permissao" do
    login_as :admin
    get :update
    response.should redirect_to(login_path)
  end

end
