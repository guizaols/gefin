module AuthenticatedTestHelper
  # Sets the current usuario in the session from the usuario fixtures.
  def login_as(usuario)
    request.session[:usuario_id] = usuario ? usuarios(usuario).id : nil
    request.session[:unidade_id] = usuario ? usuarios(usuario).unidade_id : nil
    request.session[:ano] = DateTime.now.strftime("%Y")
  end

  def authorize_as(usuario)
    request.env["HTTP_AUTHORIZATION"] = usuario ? ActionController::HttpAuthentication::Basic.encode_credentials(usuarios(usuario).login, 'monkey') : nil
  end
  
  # rspec
  def mock_usuario
    usuario = mock_model(Usuario, :id => 1,
      :login  => 'user_name',
      :name   => 'U. Surname',
      :to_xml => "Usuario-in-XML", :to_json => "Usuario-in-JSON", 
      :errors => [], :unidade_id=> "20053200")
    usuario
  end  
end
