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

  def self.format_amount(amount, user=false)
    return nil if amount.nil?

    if user.present?
      commas = user.configs["amount_commas"]
      decimal = user.configs["amount_decimal"]
    else
      commas = USER_CONFIG_INIT["amount_commas"]
      decimal = USER_CONFIG_INIT["amount_decimal"]
    end

    str_amount = amount.to_s
    signed = ""
    if ["+", "-"].include? str_amount[0]
      signed = str_amount[0]
      str_amount = str_amount[1...]
    end

    temp = str_amount.split(".")
    
    if commas
      l = temp[0]
      i = 0
      ret = ""
      len = l.length
      while i < len
        if [3,5,7,9].include? i
          ret = "," + ret
        end
        ret = l[len-i-1] + ret
        i += 1
      end
    else
      ret = temp[0]
    end
    
    if decimal
      if temp.length == 2
        ret = ret + "." + temp[1] unless temp[1].to_f == 0.0
      end
    end
    
    return signed + ret
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

  def self.get_date_code_month(date)
    "#{date.year}_#{date.month}"
  end

  def self.get_date_code_year(date)
    "#{date.year}"
  end
end