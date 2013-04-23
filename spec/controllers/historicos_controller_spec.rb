require File.dirname(__FILE__) + '/../spec_helper'

describe HistoricosController do
  
  before do
    login_as 'quentin'
  end
  
  describe "handling GET /historicos" do

    before(:each) do
      @historico = mock_model(Historico, :entidade_id => entidades(:senai).id)
      Historico.stub!(:find).and_return([@historico])
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
  
    it "should find all historicos" do
      Historico.should_receive(:find).with(:all, {:order=>'descricao ASC' , :conditions=>{ :entidade_id => entidades(:senai).id} }).and_return([@historico])
      do_get
    end
  
    it "should assign the found historicos for the view" do
      do_get
      assigns[:historicos].should == [@historico]
    end
  end

  describe "handling GET /historicos/new" do

    before(:each) do
      @historico = mock_model(Historico)
      Historico.stub!(:new).and_return(@historico)
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
  
    it "should create an new historico" do
      Historico.should_receive(:new).and_return(@historico)
      do_get
    end
  
    it "should not save the new historico" do
      @historico.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new historico for the view" do
      do_get
      assigns[:historico].should equal(@historico)
    end
  end

  describe "handling GET /historicos/1/edit" do

    before(:each) do
      @historico = mock_model(Historico, :entidade_id => entidades(:senai).id)
      Historico.stub!(:find).and_return(@historico)
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
  
    it "should find the historico requested" do
      Historico.should_receive(:find).and_return(@historico)
      do_get
    end
  
    it "should assign the found Historico for the view" do
      do_get
      assigns[:historico].should equal(@historico)
    end
  end

  describe "handling POST /historicos" do

    before(:each) do
      @historico = mock_model(Historico, :to_param => "1")
      Historico.stub!(:new).and_return(@historico)
    end
    
    describe "with successful save" do
  
      def do_post
        @historico.should_receive(:entidade_id=).with(entidades(:senai).id).and_return true
        @historico.should_receive(:save).and_return(true)
        post :create, :historico => {:descricao=>'teste'}
      end
        
      it "deve criar historico " do
        historico = mock_model(Historico, :descricao => 'teste')
        Historico.should_receive(:new).with('descricao'=>'teste').and_return historico
        historico.should_receive(:entidade_id=).with(entidades(:senai).id).and_return true
        historico.should_receive(:save).and_return true
        post :create, {:historico => { :descricao=>'teste' }}
        response.should redirect_to(historicos_path)
      end
      

      it "should redirect to the new historico" do
        do_post
        response.should redirect_to(historicos_url)
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @historico.should_receive(:entidade_id=).with(entidades(:senai).id).and_return true
        @historico.should_receive(:save).and_return(false)
        post :create, :historico => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /historicos/1" do

    before(:each) do
      @historico = mock_model(Historico, :entidade_id => entidades(:senai).id, :to_param => "1")
      Historico.stub!(:find).and_return(@historico)
    end
    
    describe "with successful update" do

      def do_put
        @historico.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the historico requested" do
        Historico.should_receive(:find).with("1").and_return(@historico)
        do_put
      end

      it "should update the found historico" do
        do_put
        assigns(:historico).should equal(@historico)
      end

      it "should assign the found historico for the view" do
        do_put
        assigns(:historico).should equal(@historico)
      end

      it "should redirect to the historico" do
        do_put
        response.should redirect_to(historicos_path)
      end

    end
    
    describe "with failed update" do

      def do_put
        @historico.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /historicos/1" do

    before(:each) do
      @historico = mock_model(Historico, :entidade_id => entidades(:senai).id, :destroy => true)
      Historico.stub!(:find).and_return(@historico)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the historico requested" do
      Historico.should_receive(:find).with("1").and_return(@historico)
      do_delete
    end
  
    it "should call destroy on the found historico" do
      @historico.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the historicos list" do
      do_delete
      response.should redirect_to(historicos_url)
    end
  end

  it "testa auto_complete de historico" do
    post :auto_complete_for_historico, :argumento => "car"
    response.should be_success
    response.should have_tag("ul") do
      with_tag("li[id=?]", historicos(:pagamento_cartao).id, 'Pagamento Cartão')
    end
  end
 
  it "testa auto_complete de historico com termina_em" do
    post :auto_complete_for_historico, :argumento => "*car"
    response.should be_success
    response.should have_tag("ul") do
      with_tag "li", 0
    end
  end

  describe "Verifica se" do
    
    it "bloqueia usuário admin que não possui acesso ao model Histórico action new" do
      login_as :admin
      get :new
      response.should redirect_to(login_path)
    end
      
    it "bloqueia usuário juvenal que não possui acesso ao model Histórico action new" do
      login_as :juvenal
      get :new
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuário admin que não possui acesso ao model Histórico action edit" do
      login_as :admin
      historico = historicos(:pagamento_cheque)
      get :edit, :id => historico.id
      response.should redirect_to(login_path)
    end    
  end

  describe 'Filtra por entidade' do

    it 'a action index' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :index
      response.should be_success
      assigns[:historicos].should == []
    end

    it 'a action edit' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :edit, :id => historicos(:pagamento_cheque).id
      response.should redirect_to(login_path)
    end

    it 'a action destroy' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      delete :destroy, :id => historicos(:pagamento_cheque).id
      response.should redirect_to(login_path)
    end

    it 'a action update' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      put :update, :id => historicos(:pagamento_cheque).id
      response.should redirect_to(login_path)
    end

    it "auto complete de agencias passando '2' pesquisando na unidade incorreta " do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_historico, :argumento => 'Pag'
      response.should be_success
      assigns[:items].should == []
    end

  end

  describe "Teste de bloqueio das actions caso o historico padrão não seja da Entidade logada" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      @historico = historicos(:pagamento_cheque)
    end

    after do
      assigns[:historico].should == @historico
      response.should redirect_to(login_path)
    end

    [:update, :destroy].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @historico
      end
    end

  end
  
end