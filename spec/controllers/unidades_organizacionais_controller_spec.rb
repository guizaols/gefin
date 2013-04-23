require File.dirname(__FILE__) + '/../spec_helper'

describe UnidadesOrganizacionaisController do

  before do
    login_as 'quentin'
  end

  it "testa auto_complete de unidade organizacional SENAI" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_unidade_organizacional, :argumento => 's'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 3
      with_tag("li[id=?]", unidade_organizacionais(:senai_unidade_organizacional).id, '134234239039 - Senai Matriz')
      with_tag("li[id=?]", unidade_organizacionais(:senai_unidade_organizacional_nova).id, '131344278639 - Senai Novo')
      with_tag("li[id=?]", unidade_organizacionais(:unidade_organizacional_empresa).id, '999999999999 - Unidade Empresa')
      with_tag("li[id=?]", unidade_organizacionais(:sesi_colider_unidade_organizacional).id, false)
    end
  end

  it "testa auto_complete de unidade organizacional SENAI com termina_em" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_unidade_organizacional, :argumento => '*s'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 0
    end
  end

  it "testa auto_complete de unidade organizacional SESI" do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_unidade_organizacional, :argumento => 's'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 1
      with_tag("li[id=?]", unidade_organizacionais(:sesi_colider_unidade_organizacional).id, '1303010803 - SESI COLIDER')
      with_tag("li[id=?]", unidade_organizacionais(:senai_unidade_organizacional).id, false)
    end
  end
  
end
