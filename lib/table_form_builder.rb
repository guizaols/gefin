class TableFormBuilder < ActionView::Helpers::FormBuilder

  (field_helpers - %w(hidden_field)).each do |selector|
    src = <<-END_SRC
      def #{selector}(field, options = {})
        original_options = options.dup
        original_options.delete :td_options
        original_options.delete :after
        original_options.delete :label
        original_options.delete :simple_tag
        options.reverse_merge! :after => '', :td_options => {}
        begin
          model = self.object_name.to_s.camelize.constantize
          if options[:after].empty? && !(ajuda = model.ajuda_para(field)).blank?
            options[:after] = ' <a href="#" onclick="alert(\\'' + ajuda.to_s.gsub("\\n", '\\n').gsub('"', '&quot;').gsub("'", '&quot;') + '\\'); return false;"><img alt="Ajuda" height="11" src="/images/ajuda.png" width="11" /></a>' if ajuda
          end
        rescue
        end
        options[:td_options].reverse_merge! :class => 'field_descriptor'
        if options.delete(:simple_tag)
          super(field, original_options)
        else
          @template.content_tag('tr', 
            @template.content_tag('td', options[:label] || field.to_s.humanize, options[:td_options]) +
            @template.content_tag('td', super(field, original_options) + options[:after])
          )
        end
      end
    END_SRC
    class_eval src, __FILE__, __LINE__
    
  end

end