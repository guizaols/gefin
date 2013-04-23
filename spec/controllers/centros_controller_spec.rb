require File.dirname(__FILE__) + '/../spec_helper'

describe CentrosController do

  before do
    login_as 'quentin'
  end

  it "testa auto_complete de centros SENAI" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_centro, :argumento => 'f', :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional).id
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 2
      with_tag("li[id=?]", centros(:centro_forum_economico).id, '4567456344 - Forum Serviço Economico')
      with_tag("li[id=?]", centros(:centro_forum_financeiro).id, '124453343 - Forum Serviço Financeiro')
      with_tag("li[id=?]", centros(:centro_forum_social).id, false)
    end
  end

  it "testa auto_complete de centros SENAI NOVO" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_centro, :argumento => 'f', :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional_nova).id
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 1
      with_tag("li[id=?]", centros(:centro_forum_financeiro).id, '124453343 - Forum Serviço Financeiro')
      with_tag("li[id=?]", centros(:centro_forum_economico).id, false)
      with_tag("li[id=?]", centros(:centro_forum_social).id, false)
    end
  end

  it "testa auto_complete de centros SESI" do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_centro, :argumento => 'f', :unidade_organizacional_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 1
      with_tag("li[id=?]", centros(:centro_forum_social).id, '310010405 - Forum Serviço Social')
      with_tag("li[id=?]", centros(:centro_forum_economico).id, false)
      with_tag("li[id=?]", centros(:centro_forum_financeiro).id, false)
    end
  end

  it "testa auto_complete de centros com termina_em" do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_centro, :argumento => '*Forum', :unidade_organizacional_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 0
    end
  end

end
