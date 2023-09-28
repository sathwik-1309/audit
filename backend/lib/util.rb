module Util
  def self.processed_name(name)
    if Util.has_upper_case(name)
      return name
    else
      return name.titleize
    end
  end

  def self.has_upper_case(str)
    !str.match(/[A-Z]/).nil?
  end
end