module PerfisHelper

  def lista_permicoes(permissoes, disabled)
    str = ""
    permissoes.each do |perm|
      unless perm[1].blank?
        str << "<li>#{check_box_tag "permissao_#{perm[1]}",'S',(@perfil.permissao[perm[1]..perm[1]] == 'S' rescue false), :name=>"permissao[#{perm[1]}]", :class => 'selecionaveis', :disabled => disabled}"
        str << " #{label_tag "permissao_#{perm[1]}",perm[0]}<br />"
      else
        str << "<li>#{perm[0]}<br />"
      end
      unless perm[2].blank?
        str << "<ul style='list-style: none'>"
        str << lista_permicoes(perm[2], disabled)
        str << "</ul>"
      end
      str << "</li>"
    end
    str
  end

end
