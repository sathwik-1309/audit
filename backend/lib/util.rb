module Util
  def self.processed_name(name)
    return nil if name.nil?
    if Util.has_upper_case(name)
      return name
    else
      return name.titleize
    end
  end

  def self.has_upper_case(str)
    !str.match(/[A-Z]/).nil?
  end

  def self.init_pie_category(category, color)
    init_hash = {
      "category" => category,
      "transactions" => [],
      "percentage" => 0,
      "expenditure" => 0,
      "color" => color
    }
  end
end