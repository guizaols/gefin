module ActionView::Helpers::FormTagHelper

  def text_field_tag(name, value = nil, options = {})
    tag :input, { "type" => "text", "name" => name, "id" => sanitize_to_id(name), "value" => value }.update(options.stringify_keys)
  end

  def check_box_tag(name, value = "1", checked = false, options = {})
    html_options = { "type" => "checkbox", "name" => name, "id" => sanitize_to_id(name), "value" => value }.update(options.stringify_keys)
    html_options["checked"] = "checked" if checked
    tag :input, html_options
  end

  def select_tag(name, option_tags = nil, options = {})
    html_name = (options[:multiple] == true && !name.to_s.ends_with?("[]")) ? "#{name}[]" : name
    content_tag :select, option_tags, { "name" => html_name, "id" => sanitize_to_id(name) }.update(options.stringify_keys)
  end
  
  def sanitize_to_id(name)
    name.to_s.gsub(']','').gsub(/[^-a-zA-Z0-9:.]/, "_")
  end
      
end

class ActiveRecord::RecordInvalid
  def initialize(record)
    @record = record
    super(@record.errors.full_messages.join(", "))
  end
end

File.delete(RAILS_ROOT + '/public/javascripts/all.js') if File.exists?(RAILS_ROOT + '/public/javascripts/all.js')
File.delete(RAILS_ROOT + '/public/stylesheets/all.css') if File.exists?(RAILS_ROOT + '/public/stylesheets/all.css')

#module Mongrel
#  RecebimentoDeConta.teste
#end