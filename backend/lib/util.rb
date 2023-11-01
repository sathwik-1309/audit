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

  def self.month_year_to_start_end_date(month, year)
    # Create a date object based on the month and year
    date = Date.parse("#{month} #{year}")
  
    # Calculate the start_date as the first day of the month
    start_date = date.beginning_of_month.strftime('%Y-%m-%d')
  
    # Calculate the end_date as the last day of the month
    end_date = date.end_of_month.strftime('%Y-%m-%d')
  
    return start_date, end_date
  end
end