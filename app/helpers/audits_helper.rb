module AuditsHelper

  def traduzir_action(action)
    case action
    when 'create'; 'Criação'
    when 'update'; 'Atualização'
    when 'destroy'; 'Exclusão'
    when 'relatorio'; 'Relatório Gerado'
    end
  end

  def retorna_classes_para_combo(selected = nil)
    array_classes = ['']
    Dir.glob(RAILS_ROOT + "/app/models/*").collect{|file| classe = File.basename(file).gsub('.rb', '').camelize; array_classes << [classe, classe]}
    options_for_select(array_classes, selected)
  end

end
