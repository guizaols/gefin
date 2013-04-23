require File.dirname(__FILE__) + '/../spec_helper'

describe PerfisController do

  integrate_views

  describe 'usando o quentin' do
    before do
      login_as :quentin
    end

    it 'should get index' do
      get :index
      response.should be_success
      response.should render_template('index')
      response.should have_tag("table[class = ?]","listagem") do
        response.should have_tag("a[href = ?]",new_perfil_path)
        [['6','Consulta'],['7','Contador'],['2','Gerente'],
          ['1','Master'],['5','Operador CP'],['4','Operador CR'],
          ['3','Operador Financeiro']].each_with_index do |perfil,idx|
          with_tag("tr[class = ?]",(idx.odd? ? 'par' : 'impar')) do
            with_tag("td") do
              with_tag("a[href = ?]",'/perfis/'+perfil[0],perfil[1])
            end
            with_tag("td[class = ?]",'ultima_coluna') do
              with_tag("a[href = ?]","/perfis/#{perfil[0]}/edit") do
                with_tag("img[alt = ?][src =?]",'Alterar',%r{/images/layout/alterar.png\?.*})
              end
              with_tag("a[href = ?][onclick=?]",'/perfis/'+perfil[0], %r{.*Confirma a exclusão\?.*method = \'POST\'.*input.*name.*method.*\'value\', \'delete\'\); f\.appendChild\(m\);f\.submit\(\);.*}) do
                with_tag("img[alt = ?][src = ?]",'Excluir', %r{/images/layout/excluir.png\?.*})
              end
            end
          end
        end
      end
    end

    it 'access the path new' do
      get :new
      response.should be_success
      response.should render_template('new')
      response.should have_tag('div[id=?]','conteudo') do
        with_tag('div[id=?]','formulario') do
          with_tag("form[action=?][class=?][id=?][method=?]",'/perfis','new_perfil','new_perfil','post')
          with_tag("table") do
            with_tag('tr') do
              with_tag("td[class=?]",'field_descriptor','Nome do Perfil:')
              with_tag("td")
              with_tag("input[id=?][name=?][type=?]",'perfil_descricao','perfil[descricao]','text')
              with_tag("select[id=?][name=?][onchange=?]",'perfis_antigos_','perfis_antigos[]',%r{new Ajax\.Request\(\'\/perfis\/update_formulario\'.*parameters:'descricao=\' \+ \$\(\'perfis_antigos_\'\)\.value \+ \'\&amp;nome=\' \+ \$\(\'perfil_descricao\'\)\.value\}\).*})
            end
            with_tag('tr') do
              with_tag("td") do
                with_tag("p","Com base em:\n              \nMaster\nGerente\nOperador Financeiro\nOperador CR\nOperador CP\nConsulta\nContador")
              end
            end
            with_tag('tr') do
              with_tag('td')
              with_tag('td') do
                with_tag('ul') do
                  lista_permicoes_teste(Perfil.lista_de_permissoes_para_view, false)
                end
              end
            end
            with_tag('tr') do
              with_tag('td') do
                with_tag("input[type=?]",'submit')
              end
            end
          end
          with_tag("a[href=?]",'/perfis','Voltar')
        end
      end
    end

    it 'access the path edit' do
      get :edit, :id=>perfis(:gerente_main).id
      response.should be_success
      response.should render_template('edit')
      response.should have_tag('div[id=?]','conteudo') do
        with_tag('div[id=?]','formulario') do
          with_tag("form[action=?][class=?][id=?][method=?]","/perfis/#{perfis(:gerente_main).id}",'edit_perfil',"edit_perfil_#{perfis(:gerente_main).id}",'post') do
            with_tag("input[name=?][type=?][value=?]","_method",'hidden','put')
          end
          with_tag("table") do
            with_tag('tr') do
              with_tag("td[class=?]",'field_descriptor','Nome do Perfil:')
              with_tag("td")
              with_tag("input[id=?][name=?][type=?]",'perfil_descricao','perfil[descricao]','text')
            end
            Perfil.lista_de_permissoes_para_view.each do |permissao|
              with_tag('tr') do
                with_tag('td')
                with_tag('td') do
                  num=permissao[1]
                  if perfis(:gerente_main).permissao[num..num] == 'S'
                    with_tag("input[id=?][name=?][type='checkbox'][checked='checked']","permissao_#{num}","permissao[#{num}]")
                  else
                    with_tag("input[id=?][name=?][type='checkbox']","permissao_#{num}","permissao[#{num}]")
                  end
                  with_tag("label[for=?]","permissao_#{num}",permissao[0])
                end
              end
            end
            with_tag('tr') do
              with_tag('td') do
                with_tag("input[type=?]",'submit')
              end
            end
          end
          with_tag("a[href=?]",'/perfis','Voltar')
        end
      end
    end

    it 'access the path show' do
      perfil = perfis(:master_main)
      get :show, :id=>perfil.id
      response.should be_success
      response.should render_template('show')
      response.should have_tag('div[id=?]','conteudo') do
        with_tag('p',"Descrição: Master")
        Perfil.lista_de_permissoes_para_view.each do |permissao|
          num=permissao[1]
          if perfil.permissao[num..num] == 'S'
            with_tag("input[disabled='disabled'][type='checkbox'][checked='checked']")
          else
            with_tag("input[disabled='disabled'][type='checkbox']")
          end
          with_tag("a[href=?]", "/perfis/#{perfil.id}/edit", 'Alterar')
          with_tag("a[href=?]", "/perfis", 'Voltar')
        end
      end
    end

    it 'allows signup' do
      lambda do
        post :create, {"commit"=>"Salvar", "perfil"=>{"descricao"=>"Pesquisa"}, "permissao"=>{"11"=>"S", "7"=>"S", "12"=>"S", "23"=>"S", "57"=>"S", "14"=>"S", "58"=>"S", "15"=>"S", "4"=>"S", "5"=>"S"}}
        response.should be_redirect
      end.should change(Perfil, :count).by(1)
    end

    it 'allows destroy' do
      lambda do
        delete :destroy, :id=>perfis(:contador_main).id
        response.should be_redirect
      end.should change(Perfil, :count).by(-1)
    end

    it 'allows update' do
      put :update, {:id=>perfis(:contador_main).id,"commit"=>"Salvar", "perfil"=>{}, "permissao"=>{}}
      response.should be_redirect
      Perfil.find(perfis(:contador_main).id).permissao.should == "NNNNNNNSNSSNSNNNNNNNNNNNNNNNNNNNNNNNNNSNSNSNSNSSSNNNSNNNNSSSSNNNNNNNNNNNNNNNN"
    end
  end




  describe 'usando o aaron' do
    before do
      login_as :aaron
    end

    it 'should get index' do
      get :index
      response.should be_success
      response.should render_template('index')
      response.should have_tag("table[class = ?]","listagem") do
        response.should_not have_tag("a[href = ?]",new_perfil_path)
        [['6','Consulta'],['7','Contador'],['2','Gerente'],
          ['1','Master'],['5','Operador CP'],['4','Operador CR'],
          ['3','Operador Financeiro']].each_with_index do |perfil,idx|
          with_tag("tr[class = ?]",(idx.odd? ? 'par' : 'impar')) do
            with_tag("td") do
              with_tag("a[href = ?]",'/perfis/'+perfil[0],perfil[1])
            end
            with_tag("td[class = ?]",'ultima_coluna') do
              without_tag("a[href = ?]","/perfis/#{perfil[0]}/edit") do
                without_tag("img[alt = ?][src =?]",'Alterar',%r{/images/layout/alterar.png\?.*})
              end
              without_tag("a[href = ?][onclick=?]",'/perfis/'+perfil[0], %r{.*Confirma a exclusão\?.*method = \'POST\'.*input.*name.*method.*\'value\', \'delete\'\); f\.appendChild\(m\);f\.submit\(\);.*}) do
                without_tag("img[alt = ?][src = ?]",'Excluir', %r{/images/layout/excluir.png\?.*})
              end
            end
          end
        end
      end
    end

    it 'access the path new' do
      get :new
      response.should redirect_to(login_path)
    end

    it 'access the path edit' do
      get :edit, :id=>perfis(:gerente_main).id
      response.should redirect_to(login_path)
    end

    it 'access the path show' do
      perfil = perfis(:master_main)
      get :show, :id => perfil.id
      response.should be_success
      response.should render_template('show')
      response.should have_tag('div[id=?]','conteudo') do
        with_tag('p',"Descrição: Master")
        Perfil.lista_de_permissoes_para_view.each do |permissao|
          num = permissao[1]
          if perfil.permissao[num..num] == 'S'
            with_tag("input[disabled='disabled'][type='checkbox'][checked='checked']")
          else
            with_tag("input[disabled='disabled'][type='checkbox']")
          end
        end
        without_tag("a[href=?]", "/perfis/#{perfil.id}/edit", 'Alterar')
        with_tag("a[href=?]", "/perfis", 'Voltar')
      end
    end

    it 'allows signup' do
      lambda do
        post :create, {"commit"=>"Salvar", "perfil"=>{"descricao"=>"Pesquisa"}, "permissao"=>{"11"=>"S", "7"=>"S", "12"=>"S", "23"=>"S", "57"=>"S", "14"=>"S", "58"=>"S", "15"=>"S", "4"=>"S", "5"=>"S"}}
        response.should redirect_to(login_path)
      end.should_not change(Perfil, :count).by(1)
    end

    it 'allows destroy' do
      lambda do
        delete :destroy, :id=>perfis(:contador_main).id
        response.should redirect_to(login_path)
      end.should_not change(Perfil, :count).by(-1)
    end

    it 'allows update' do
      put :update, {:id=>perfis(:contador_main).id,"commit"=>"Salvar", "perfil"=>{}, "permissao"=>{}}
      response.should redirect_to(login_path)
      Perfil.find(perfis(:contador_main).id).permissao.should_not == "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"
    end
  end



  describe 'usando o juvenal' do
    before do
      login_as :juvenal
    end

    it 'should get index' do
      get :index
      response.should redirect_to(login_path)
    end

    it 'access the path new' do
      get :new
      response.should redirect_to(login_path)
    end

    it 'access the path edit' do
      get :edit, :id=>perfis(:gerente_main).id
      response.should redirect_to(login_path)
    end

    it 'access the path show' do
      get :show, :id=>perfis(:gerente_main).id
      response.should redirect_to(login_path)
    end

    it 'allows signup' do
      lambda do
        post :create, {"commit"=>"Salvar", "perfil"=>{"descricao"=>"Pesquisa"}, "permissao"=>{"11"=>"S", "7"=>"S", "12"=>"S", "23"=>"S", "57"=>"S", "14"=>"S", "58"=>"S", "15"=>"S", "4"=>"S", "5"=>"S"}}
        response.should redirect_to(login_path)
      end.should_not change(Perfil, :count).by(1)
    end

    it 'allows destroy' do
      lambda do
        delete :destroy, :id=>perfis(:contador_main).id
        response.should redirect_to(login_path)
      end.should_not change(Perfil, :count).by(-1)
    end

    it 'allows update' do
      put :update, {:id=>perfis(:contador_main).id,"commit"=>"Salvar", "perfil"=>{}, "permissao"=>{}}
      response.should redirect_to(login_path)
      Perfil.find(perfis(:contador_main).id).permissao.should_not == "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"
    end
  end
  describe 'ao tentar destruir o perfil' do
    before do
      login_as :quentin
    end

    it 'allows destroy not used perfis' do
      delete :destroy, :id=>perfis(:operador_cp_main).id
      response.should redirect_to(perfis_path)
      get :index
      response.should be_success
      response.body.should_not match(%r(alert\("Perfil n\\u00e3o pode ser exclu\\u00eddo enquanto estiver ligado ao\(s\) usu\\u00e1rio\(s\):));
    end

    it 'dont allows destroy if perfil is used' do
      delete :destroy, :id=>perfis(:gerente_main).id
      response.should redirect_to(perfis_path)
      get :index
      response.should be_success
      response.body.should match(%r(alert\("Perfil n\\u00e3o pode ser exclu\\u00eddo enquanto estiver ligado ao\(s\) usu\\u00e1rio\(s\): Juan Vitor Zeferino"\);));
    end
  end

  def lista_permicoes_teste(permissoes, disabled,select_permissoes = "")
    permissoes.each do |perm|
      unless perm[1].blank?
        with_tag('li') do
          if select_permissoes[perm[1]..perm[1]] == 'S'
            if disabled
              with_tag("input[id=?][disabled='disabled'][checked='checked'][name=?][type='checkbox']","permissao_#{perm[1]}","permissao[#{perm[1]}]")
            else
              with_tag("input[id=?][checked='checked'][name=?][type='checkbox']","permissao_#{perm[1]}","permissao[#{perm[1]}]")
            end
          else
            if disabled
              with_tag("input[id=?][disabled='disabled'][name=?][type='checkbox']","permissao_#{perm[1]}","permissao[#{perm[1]}]")
            else
              with_tag("input[id=?][name=?][type='checkbox']","permissao_#{perm[1]}","permissao[#{perm[1]}]")
            end
          end
          with_tag("label[for=?]","permissao_#{perm[1]}",perm[0])
          unless perm[2].blank?
            with_tag('ul') do
              lista_permicoes_teste(perm[2], disabled, select_permissoes)
            end
          end
        end
      else
        with_tag('li', "#{perm[0]}") do
          unless perm[2].blank?
            with_tag('ul') do
              lista_permicoes_teste(perm[2], disabled, select_permissoes)
            end
          end
        end
      end
    end
  end

end
