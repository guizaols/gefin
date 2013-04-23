require File.dirname(__FILE__) + '/../spec_helper'

describe EntidadesController do
  
  describe "handling GET /entidades" do
    before do
      login_as 'quentin'
    end
    
    before(:each) do
      @entidade = mock_model(Entidade)
      Entidade.stub!(:find).and_return([@entidade])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all entidades" do
      Entidade.should_receive(:find).with(:all, :order => 'nome ASC').and_return([@entidade])
      do_get
    end
  
    it "should assign the found entidades for the view" do
      do_get
      assigns[:entidades].should == [@entidade]
    end
  end

  describe "handling GET /entidades/1" do
    before do
      login_as 'quentin'
    end
    before(:each) do
      @entidade = mock_model(Entidade)
      Entidade.stub!(:find).and_return(@entidade)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the entidade requested" do
      Entidade.should_receive(:find).with("1").and_return(@entidade)
      do_get
    end
  
    it "should assign the found entidade for the view" do
      do_get
      assigns[:entidade].should equal(@entidade)
    end
  end

#  describe "handling GET /entidades/new" do
#    before do
#      login_as 'quentin'
#    end
#    before(:each) do
#      @entidade = mock_model(Entidade)
#      Entidade.stub!(:new).and_return(@entidade)
#    end
#
#    def do_get
#      get :new
#    end
#
#    it "should be successful" do
#      do_get
#      response.should be_success
#    end
#
#    it "should render new template" do
#      do_get
#      response.should render_template('new')
#    end
#
#    it "should create an new entidade" do
#      Entidade.should_receive(:new).and_return(@entidade)
#      do_get
#    end
#
#    it "should not save the new entidade" do
#      @entidade.should_not_receive(:save)
#      do_get
#    end
#
#    it "should assign the new entidade for the view" do
#      do_get
#      assigns[:entidade].should equal(@entidade)
#    end
#  end
#
#  describe "handling GET /entidades/1/edit" do
#    before do
#      login_as 'quentin'
#    end
#    before(:each) do
#      @entidade = mock_model(Entidade)
#      Entidade.stub!(:find).and_return(@entidade)
#    end
#
#    def do_get
#      get :edit, :id => "1"
#    end
#
#    it "should be successful" do
#      do_get
#      response.should be_success
#    end
#
#    it "should render edit template" do
#      do_get
#      response.should render_template('edit')
#    end
#
#    it "should find the entidade requested" do
#      Entidade.should_receive(:find).and_return(@entidade)
#      do_get
#    end
#
#    it "should assign the found Entidade for the view" do
#      do_get
#      assigns[:entidade].should equal(@entidade)
#    end
#  end
#
#  describe "handling POST /entidades" do
#    before do
#      login_as 'quentin'
#    end
#    before(:each) do
#      @entidade = mock_model(Entidade, :to_param => "1")
#      Entidade.stub!(:new).and_return(@entidade)
#    end
#
#    describe "with successful save" do
#
#      def do_post
#        @entidade.should_receive(:save).and_return(true)
#        post :create, :entidade => {}
#      end
#
#      it "should create a new entidade" do
#        Entidade.should_receive(:new).with({}).and_return(@entidade)
#        do_post
#      end
#
#      it "should redirect to the new entidade" do
#        do_post
#        response.should redirect_to(entidade_url("1"))
#      end
#
#    end
#
#    describe "with failed save" do
#      before do
#        login_as 'quentin'
#      end
#      def do_post
#        @entidade.should_receive(:save).and_return(false)
#        post :create, :entidade => {}
#      end
#
#      it "should re-render 'new'" do
#        do_post
#        response.should render_template('new')
#      end
#
#    end
#  end
#
#  describe "handling PUT /entidades/1" do
#    before do
#      login_as 'quentin'
#    end
#    before(:each) do
#      @entidade = mock_model(Entidade, :to_param => "1")
#      Entidade.stub!(:find).and_return(@entidade)
#    end
#
#    describe "with successful update" do
#
#      def do_put
#        @entidade.should_receive(:update_attributes).and_return(true)
#        put :update, :id => "1"
#      end
#
#      it "should find the entidade requested" do
#        Entidade.should_receive(:find).with("1").and_return(@entidade)
#        do_put
#      end
#
#      it "should update the found entidade" do
#        do_put
#        assigns(:entidade).should equal(@entidade)
#      end
#
#      it "should assign the found entidade for the view" do
#        do_put
#        assigns(:entidade).should equal(@entidade)
#      end
#
#      it "should redirect to the entidade" do
#        do_put
#        response.should redirect_to(entidade_url("1"))
#      end
#
#    end
#
#    describe "with failed update" do
#      before do
#        login_as 'quentin'
#      end
#      def do_put
#        @entidade.should_receive(:update_attributes).and_return(false)
#        put :update, :id => "1"
#      end
#
#      it "should re-render 'edit'" do
#        do_put
#        response.should render_template('edit')
#      end
#
#    end
#  end
  
  it "Testa se chama a action Index sem estar logado" do
    get :index
    response.should redirect_to(new_sessao_path)
  end

  
#  describe "handling DELETE /entidades/1" do
#    before do
#      login_as 'quentin'
#    end
#    before(:each) do
#      @entidade = mock_model(Entidade, :destroy => true)
#      Entidade.stub!(:find).and_return(@entidade)
#    end
#
#    def do_delete
#      delete :destroy, :id => "1"
#    end
#
#    it "should find the entidade requested" do
#      Entidade.should_receive(:find).with("1").and_return(@entidade)
#      do_delete
#    end
#
#    it "should call destroy on the found entidade" do
#      @entidade.should_receive(:destroy)
#      do_delete
#    end
#
#    it "should redirect to the entidades list" do
#      do_delete
#      response.should redirect_to(entidades_url)
#    end
#  end
  
  describe "Verifica se" do
    
    it "bloqueia o acesso do usuario admin para action new" do
      login_as :admin
      get :new
      response.should redirect_to(login_path)
    end
    
    it "bloqueia o acesso de usuario admin para action edit" do
      login_as :admin
      entidade = entidades(:senai)
      post :edit, :id=> entidade.id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia o acesso de usuario admin para action destroy" do
      login_as :admin
      entidade = entidades(:senai)
      delete :destroy, :id=> entidade.id
      response.should redirect_to(login_path)
    end
    
  end
end