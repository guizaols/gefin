class Count < ActiveRecord::Base

  def self.search_or_create_and_update class_name, operator
    encoded_class_name = Base64.encode64(class_name)
    class_count = class_name.constantize.count
    count = Count.find_by_tn(encoded_class_name) || Count.new(:tn => encoded_class_name, :number => class_count)
    new_number = count.number + operator
    if !count.new_record? && (new_number != class_count)
      Change.create! :tn => encoded_class_name, :msg => Base64.encode64("Should have #{new_number} but got #{class_count} records.")
    end
    count.number = class_count
    count.save
  end

end
