require File.dirname(__FILE__) + '/../spec_helper'

describe LocalidadesController do

  before do
    login_as 'quentin'
  end 
  
  describe "handling GET /localidades" do    

    integrate_views
    
    def do_get
      get :index, :busca => ""
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
    
    it "deve carregar os dados corretamente" do
      localidades = [localidades(:primeira)]
      get :index, :busca => "varzea"
      
      assigns[:localidades].should == localidades
      response.should be_success
      
      response.should have_tag("table[class='listagem']") do
        with_tag('td', 4)
      end      
    end
  
    it "should find all localidades" do      
      get :index, :busca => "a"
      response.should be_success
      
      response.should have_tag("table[class='listagem']") do
        with_tag('td', 7)
      end
    end
  end

  describe "handling GET /localidades/new" do

    before(:each) do
      @localidade = mock_model(Localidade)
      Localidade.stub!(:new).and_return(@localidade)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new localidade" do
      Localidade.should_receive(:new).and_return(@localidade)
      do_get
    end
  
    it "should not save the new localidade" do
      @localidade.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new localidade for the view" do
      do_get
      assigns[:localidade].should equal(@localidade)
    end
  end

  describe "handling GET /localidades/1/edit" do

    before(:each) do
      @localidade = mock_model(Localidade)
      Localidade.stub!(:find).and_return(@localidade)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the localidade requested" do
      Localidade.should_receive(:find).and_return(@localidade)
      do_get
    end
  
    it "should assign the found Localidade for the view" do
      do_get
      assigns[:localidade].should equal(@localidade)
    end
  end

  describe "handling POST /localidades" do

    before(:each) do
      @localidade = mock_model(Localidade, :to_param => "1")
      Localidade.stub!(:new).and_return(@localidade)
    end
    
    describe "with successful save" do
  
      def do_post
        @localidade.should_receive(:save).and_return(true)
        post :create, :localidade => {}
      end
  
      it "should create a new localidade" do
        Localidade.should_receive(:new).with({}).and_return(@localidade)
        do_post
      end

      it "should redirect to the new localidade" do
        do_post
        response.should redirect_to(localidades_path)
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @localidade.should_receive(:save).and_return(false)
        post :create, :localidade => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /localidades/1" do

    before(:each) do
      @localidade = mock_model(Localidade, :to_param => "1")
      Localidade.stub!(:find).and_return(@localidade)
    end
    
    describe "with successful update" do

      def do_put
        @localidade.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the localidade requested" do
        Localidade.should_receive(:find).with("1").and_return(@localidade)
        do_put
      end

      it "should update the found localidade" do
        do_put
        assigns(:localidade).should equal(@localidade)
      end

      it "should assign the found localidade for the view" do
        do_put
        assigns(:localidade).should equal(@localidade)
      end

      it "should redirect to the localidade" do
        do_put
        response.should redirect_to(localidades_url)
      end

    end
    
    describe "with failed update" do

      def do_put
        @localidade.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /localidades/1" do

    before(:each) do
      @localidade = mock_model(Localidade, :destroy => true)
      Localidade.stub!(:find).and_return(@localidade)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end
    
    it "should find the localidade requested" do
      Localidade.should_receive(:find).with("1").and_return(@localidade)
      do_delete
    end
  
    it "should call destroy on the found localidade" do
      @localidade.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the localidades list" do
      do_delete
      response.should redirect_to(localidades_url)
    end
  end
  
  describe "Verifica se" do
    
    it "testa auto_complete de localidades" do
      login_as :quentin
      post :auto_complete_for_localidade , :argumento => 'a'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]",localidades(:primeira).id,'VARZEA GRANDE - MT')
        with_tag("li[id=?]",localidades(:segunda).id,'CUIABA - MT')
      end      
    end
    
    it "testa auto_complete de localidades com termina_em" do
      login_as :quentin
      post :auto_complete_for_localidade , :argumento => '*a'
      response.should be_success
      response.should have_tag("ul") do
        with_tag 'li', 1
        with_tag("li[id=?]",localidades(:segunda).id,'CUIABA - MT')
      end
    end

    it "testa auto_complete de localidades passando 'var' " do
      login_as :quentin
      post :auto_complete_for_localidade , :argumento => 'var'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", localidades(:primeira).id,'VARZEA GRANDE - MT')
      end      
    end

    it "testa auto_complete de localidades passando 'var' com usuario que tem perfil 2 " do
      login_as :aaron
      post :auto_complete_for_localidade , :argumento => 'var'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", localidades(:primeira).id,'VARZEA GRANDE - MT')
      end
    end

    it "testa auto_complete de localidades passando 'var' com usuario que tem perfil 3 " do
      login_as :old_password_holder
      post :auto_complete_for_localidade , :argumento => 'var'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", localidades(:primeira).id,'VARZEA GRANDE - MT')
      end
    end

    it "testa auto_complete de localidades passando 'var' com usuario que tem perfil 4 " do
      login_as :admin
      post :auto_complete_for_localidade , :argumento => 'var'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", localidades(:primeira).id,'VARZEA GRANDE - MT')
      end
    end

    it "testa auto_complete de localidades passando 'var' com usuario que tem perfil 5 " do
      usuario = usuarios(:quentin)
      usuario.perfil_id = 5
      usuario.save!
      login_as :quentin
      post :auto_complete_for_localidade , :argumento => 'var'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", localidades(:primeira).id,'VARZEA GRANDE - MT')
      end
    end

    it "testa auto_complete de localidades passando 'var' com usuario que tem perfil 6 " do
      login_as :juvenal
      post :auto_complete_for_localidade , :argumento => 'var'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", localidades(:primeira).id,'VARZEA GRANDE - MT')
      end
    end

    it "testa auto_complete de localidades passando 'var' com usuario que tem perfil 7 " do
      usuario = usuarios(:quentin)
      usuario.perfil_id = 7
      usuario.save!
      login_as :quentin
      post :auto_complete_for_localidade , :argumento => 'var'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", localidades(:primeira).id,'VARZEA GRANDE - MT')
      end
    end
    
    it "bloqueia usuario juvenal sem permissao ao tentar modificar dados no model Localidade action edit" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal
      
      localidade = localidades(:primeira)
      get :edit, :id=>localidade.id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario juvenal sem permissao ao tentar modificar dados no model Localidade action destroy" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal
      
      localidade = localidades(:primeira)
      delete :destroy,:id=>localidade.id
      response.should redirect_to(login_path)
    end
    
  end
  
end