require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeParaController do

  fixtures :all
  integrate_views

  describe 'controle de acesso para centros' do
    it 'deve negar se não estiver logado' do
      get :show, :id => 'centros'
      response.should redirect_to(new_sessao_path)
    end

    it 'deve aceitar se não estiver logado' do
      login_as :quentin
      get :show, :id => 'centros'
      response.should be_success
    end
    
    it "deve redirecionar para login caso o usuario não tenha permissãoo" do
      login_as :juvenal
      get :show, :id => 'centros'
      response.should redirect_to(login_path)
    end
  end
  
  describe 'controle de acesso para unidades organizacionais' do
    it 'deve bloquear se não estiver logado' do
      get :show, :id => 'unidade_organizacionais'
      response.should redirect_to(new_sessao_path)
    end
    
    it 'deve autorizar se ja estiver logado' do
      login_as :quentin
      get :show, :id => 'unidade_organizacionais'
      response.should be_success
    end
    
    it "deve redirecionar para login caso o usuario não tenha permissão" do
      login_as :juvenal
      get :show, :id => 'unidade_organizacionais'
      response.should redirect_to(login_path)
    end
  end

  describe 'deve gerenciar centros e' do
    it 'exibir os centros do ano atual' do
      login_as :juliano
      request.session[:ano] = "2009"
      get :show, :id => 'centros'
      response.should be_success

      assigns[:objetos_deste_ano].should == Centro.find_all_by_entidade_id_and_ano(entidades(:sesi).id, 2009, :order => 'codigo_centro')
      assigns[:objetos_do_ano_passado].should == Centro.find_all_by_entidade_id_and_ano(entidades(:sesi).id, 2008, :order => 'codigo_centro')

      response.should have_tag 'div#ano_passado' do
        with_tag 'p', '2008'
      end
      response.should have_tag 'div#ano_corrente' do
        with_tag 'p', '2009'
      end

      response.should have_tag('form[action=?]', alterar_de_para_path('centros')) do
        
        with_tag 'select[name=objeto_do_ano_passado_id][size]' do
          with_tag 'option', 1
          with_tag 'option[value=?]', centros(:centro_forum_social_2008).id, '310010405 - Forum Serviço Social'
        end

        with_tag 'select[name=objeto_deste_ano_id][size]' do
          with_tag 'option', 2
          with_tag 'option', ''
          with_tag 'option[value=?]', centros(:centro_forum_social).id, '310010405 - Forum Serviço Social'
        end

        with_tag 'input[type=submit][value=Confirmar][disabled]'
        with_tag 'input[type=submit][value=Cancelar][disabled]'
      end

    end
  end
  
  describe 'deve gerenciar unidades organizacionais e' do
    it 'exibir as unidades organizacionais do ano atual' do
      login_as :juliano
      request.session[:ano] = "2009"
      get :show, :id => 'unidade_organizacionais'
      response.should be_success
 
      assigns[:objetos_deste_ano].should == UnidadeOrganizacional.find_all_by_entidade_id_and_ano(entidades(:sesi).id, 2009, :order => 'codigo_da_unidade_organizacional') 
      assigns[:objetos_do_ano_passado].should == UnidadeOrganizacional.find_all_by_entidade_id_and_ano(entidades(:sesi).id, 2008, :order => 'codigo_da_unidade_organizacional') 
      
      response.should have_tag 'div#ano_passado' do
        with_tag 'p', '2008'
      end
      
      response.should have_tag 'div#ano_corrente' do
        with_tag 'p', '2009'
      end
      
      response.should have_tag('form[action=?]', alterar_de_para_path('unidade_organizacionais')) do
        
        with_tag 'select[name=objeto_do_ano_passado_id][size]' do
          with_tag 'option', 1
          with_tag 'option[value=?]', unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).id, '1303010803 - SESI COLIDER'
        end

        with_tag 'select[name=objeto_deste_ano_id][size]' do
          with_tag 'option', 2
          with_tag 'option', ''
          with_tag 'option[value=?]', unidade_organizacionais(:sesi_colider_unidade_organizacional).id, '1303010803 - SESI COLIDER'
        end

        with_tag 'input[type=submit][value=Confirmar][disabled]'
        with_tag 'input[type=submit][value=Cancelar][disabled]'
      end
      
    end
  end

  describe 'deve gerenciar alteracoes e' do

    it 'permitir quando cancelar centro valido' do
      centros(:centro_forum_social_2008).objeto_do_proximo_ano.should == centros(:centro_forum_social)
      
      login_as :juliano
      put :alterar, :id => 'centros', :objeto_deste_ano_id => centros(:centro_forum_social).id, :objeto_do_ano_passado_id => centros(:centro_forum_social_2008).id, :commit => 'Cancelar'
      response.should be_success

      centros(:centro_forum_social_2008).reload
      centros(:centro_forum_social_2008).objeto_do_proximo_ano.should == nil
    end
    
    it 'não permitir quando cancelar centro de unidade inválida' do
      centros(:centro_forum_social_2008).objeto_do_proximo_ano.should == centros(:centro_forum_social)

      login_as :quentin
      lambda {
        put :alterar, :id => 'centros', :objeto_deste_ano_id => centros(:centro_forum_social).id, :objeto_do_ano_passado_id => centros(:centro_forum_social_2008).id, :commit => 'Cancelar'
      }.should raise_error

      centros(:centro_forum_social_2008).reload
      centros(:centro_forum_social_2008).objeto_do_proximo_ano.should == centros(:centro_forum_social)
    end

    it 'permitir quando associar centro valido' do
      centros(:centro_forum_social_2008).update_attributes! :objeto_do_proximo_ano => nil

      login_as :juliano
      put :alterar, :id => 'centros', :objeto_deste_ano_id => centros(:centro_forum_social).id, :objeto_do_ano_passado_id => centros(:centro_forum_social_2008).id, :commit => 'Confirmar'
      response.should be_success

      centros(:centro_forum_social_2008).reload
      centros(:centro_forum_social_2008).objeto_do_proximo_ano.should == centros(:centro_forum_social)
    end

    it 'não permitir quando associar centro de unidade inválida' do
      centros(:centro_forum_social_2008).update_attributes! :objeto_do_proximo_ano => nil

      login_as :quentin
      lambda {
        put :alterar, :id => 'centros', :objeto_deste_ano_id => centros(:centro_forum_social).id, :objeto_do_ano_passado_id => centros(:centro_forum_social_2008).id, :commit => 'Confirmar'
      }.should raise_error

      centros(:centro_forum_social_2008).reload
      centros(:centro_forum_social_2008).objeto_do_proximo_ano.should == nil
    end
  end
  
  describe 'deve gerenciar alteraçoes em Unidades Organizacionais e ' do
    
    it "permitir quando cancelar unidade organizacional inválida" do
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).objeto_do_proximo_ano.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
      
      login_as :juliano
      put :alterar, :id => 'unidade_organizacionais', :objeto_deste_ano_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id, :objeto_do_ano_passado_id => unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).id, :commit => 'Cancelar'
      response.should be_success
      
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).reload
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).objeto_do_proximo_ano.should == nil
    end
    
    it "bloquear se o usuário tentar cancelar unidade organizacional de unidade invãlida" do
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).objeto_do_proximo_ano.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)

      login_as :quentin
      lambda {
        put :alterar, :id => 'unidade_organizacionais', :objeto_deste_ano_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id, :objeto_do_ano_passado_id => unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).id, :commit => 'Cancelar'
      }.should raise_error

      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).reload
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).objeto_do_proximo_ano.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    end
    
    it "permitir quando associar unidade organizacional válida" do
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).update_attributes! :objeto_do_proximo_ano => nil

      login_as :juliano
      put :alterar, :id => 'unidade_organizacionais', :objeto_deste_ano_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id, :objeto_do_ano_passado_id => unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).id, :commit => 'Confirmar'
      response.should be_success

      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).reload
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).objeto_do_proximo_ano.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    end
    
    it "bloquear quando tentar associar unidades organizacionais inválidas" do
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).update_attributes! :objeto_do_proximo_ano => nil

      login_as :quentin
      lambda {
        put :alterar, :id => 'unidade_organizacionais', :objeto_deste_ano_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id, :objeto_do_ano_passado_id => unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).id, :commit => 'Confirmar'
      }.should raise_error

      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).reload
      unidade_organizacionais(:sesi_colider_unidade_organizacional_2008).objeto_do_proximo_ano.should == nil
    end
    
  end
end
