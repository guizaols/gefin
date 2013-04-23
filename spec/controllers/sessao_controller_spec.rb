require File.dirname(__FILE__) + '/../spec_helper'

describe SessaoController do
  
  before do 
    @usuario  = mock_usuario
    @login_params = { :login => 'quentin', :password => 'test' }
    Usuario.stub!(:authenticate).with(@login_params[:login], @login_params[:password]).and_return(@usuario)
  end
  def do_create
    post :create, @login_params
  end
  describe "on successful login," do
    [ [:nil,       nil,            nil],
      [:expired,   'valid_token',  15.minutes.ago],
      [:different, 'i_haxxor_joo', 15.minutes.from_now], 
      [:valid,     'valid_token',  15.minutes.from_now]
    ].each do |has_request_token, token_value, token_expiry|
      [ true, false ].each do |want_remember_me|
        describe "my request cookie token is #{has_request_token.to_s}," do
          describe "and ask #{want_remember_me ? 'to' : 'not to'} be remembered" do 
            before do
              @ccookies = mock('cookies')
              controller.stub!(:cookies).and_return(@ccookies)
              @ccookies.stub!(:[]).with(:auth_token).and_return(token_value)
              @ccookies.stub!(:delete).with(:auth_token)
              @ccookies.stub!(:[]=)
              @ccookies.stub!(:each).and_return []
              @usuario.stub!(:remember_me) 
              @usuario.stub!(:refresh_token) 
              @usuario.stub!(:forget_me)
              @usuario.stub!(:remember_token).and_return(token_value) 
              @usuario.stub!(:remember_token_expires_at).and_return(token_expiry)
              @usuario.stub!(:remember_token?).and_return(has_request_token == :valid)
              if want_remember_me
                @login_params[:remember_me] = '1'
              else 
                @login_params[:remember_me] = '0'
              end
            end
            it "kills existing login"        do 
              controller.should_receive(:logout_keeping_session!)
              session[:ano].should == nil
              session[:unidade_id].should == nil
              do_create
               
            end
            
            it "authorizes me"               do do_create; controller.send(:authorized?).should be_true;   end    
            it "logs me in"                  do 
              do_create
              controller.send(:logged_in?).should  be_true
              session[:ano].should == 2010
              session[:unidade_id].should == 20053200
            end
            it "greets me nicely"            do do_create; response.flash[:notice].should =~ /Usuário autenticado com sucesso!/i   end
            it "sets/resets/expires cookie"  do controller.should_receive(:handle_remember_cookie!).with(want_remember_me); do_create end
            it "sends a cookie"              do controller.should_receive(:send_remember_cookie!);  do_create end
            it 'redirects to the home page'  do do_create; response.should redirect_to(main_path)   end
            it "does not reset my session"   do controller.should_not_receive(:reset_session).and_return nil; do_create end # change if you uncomment the reset_session path
            if (has_request_token == :valid)
              it 'does not make new token'   do @usuario.should_not_receive(:remember_me);   do_create end
              it 'does refresh token'        do @usuario.should_receive(:refresh_token);     do_create end 
              it "sets an auth cookie"       do do_create;  end
            else
              if want_remember_me
                it 'makes a new token'       do @usuario.should_receive(:remember_me);       do_create end 
                it "does not refresh token"  do @usuario.should_not_receive(:refresh_token); do_create end
                it "sets an auth cookie"       do do_create;  end
              else 
                it 'does not make new token' do @usuario.should_not_receive(:remember_me);   do_create end
                it 'does not refresh token'  do @usuario.should_not_receive(:refresh_token); do_create end 
                it 'kills user token'        do @usuario.should_receive(:forget_me);         do_create end 
              end
            end
          end # inner describe
        end
      end
    end
  end
  
  describe "on failed login" do
    before do
      Usuario.should_receive(:authenticate).with(anything(), anything()).and_return(nil)
      login_as :quentin
    end
    it 'logs out keeping session'   do controller.should_receive(:logout_keeping_session!); do_create end
    it 'flashes an error'           do do_create; flash[:error].should =~ /Não posso fazer login como 'quentin'/ end
    it 'renders the log in page'    do do_create; response.should render_template('new')  end
    it "doesn't log me in"          do do_create; controller.send(:logged_in?).should == false end
    it "doesn't send password back" do 
      @login_params[:password] = 'FROBNOZZ'
      do_create
      response.should_not have_text(/FROBNOZZ/i)
    end
  end

  describe "on signout" do
    def do_destroy
      get :destroy
    end
    before do 
      login_as :quentin
    end
    it 'logs me out'                   do controller.should_receive(:logout_killing_session!); do_destroy end
    it 'redirects me to the home page' do do_destroy; response.should be_redirect     end
  end
  
  it "perfil MASTER consegue alterar o ano" do
    login_as :quentin
    post :altera_ano, :ano => "2009"
    response.should be_success
    response.body.should include('window.location.reload()')
    session[:ano].should == 2009
  end

  it "perfil MASTER consegue alterar a unidade" do
    login_as :quentin
    post :altera_unidade, :unidade_id => unidades(:senaivarzeagrande).id.to_s
    response.should be_success
    response.body.should == "alert(\"Unidade alterada com sucesso!\");\nModalbox.hide()\nwindow.location.href = \"/main\";"
    session[:unidade_id].should == unidades(:senaivarzeagrande).id
  end

  it "perfil CONSULTA não consegue alterar ano" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    login_as :juvenal
    post :altera_ano, :ano => "2008"
    response.should_not be_success
  end

  it "perfil CONSULTA não consegue alterar unidade" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    login_as :juvenal
    post :altera_unidade, :unidade_id => unidades(:senaivarzeagrande).id.to_s
    response.should_not be_success
  end
  
  it "tenta alterar unidade com dados corretos" do
    login_as :quentin
    post :altera_unidade, :unidade_id => unidades(:senaivarzeagrande).id.to_s
    response.should be_success
    response.body.should == "alert(\"Unidade alterada com sucesso!\");\nModalbox.hide()\nwindow.location.href = \"/main\";"
  end

  it "tenta alterar unidade com dados inválidos" do
    login_as :quentin
    post :altera_unidade, :unidade_id => "46464846198743464"
    response.should be_success
    response.body.should == "alert(\"Dados incorretos!\");"
  end

  it "tenta alterar ano com dados corretos" do
    login_as :quentin
    post :altera_ano, :ano => "2010"
    response.should be_success
    response.body.should == "alert(\"Ano alterado com sucesso!\");\nModalbox.hide()\nwindow.location.reload()"
  end

  it "tenta alterar ano com dados inválidos" do
    login_as :quentin
    post :altera_ano, :ano => "sadasdasd4545"
    response.should be_success
    response.body.should == "alert(\"Dados incorretos!\");"
  end

end

describe SessaoController do
 
  describe "named routing" do
    before(:each) do
      get :new
    end
    it "should route sessao_path() correctly" do
      sessao_path().should == "/sessao"
    end
    it "should route new_sessao_path() correctly" do
      new_sessao_path().should == "/sessao/new"
    end
  end
  
end
