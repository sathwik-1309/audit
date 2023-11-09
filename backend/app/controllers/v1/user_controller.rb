class V1::UserController < ApplicationController
  before_action :set_current_user

  def home
    if @current_user.nil?
      render_202("User not authorized")
    end
    json = {}
    json['accounts'] = Account.list(@current_user)
    json['parties'] = Account.list(@current_user, true)
    json['sub_categories'] = @current_user.sub_categories.map{|s| s.attributes.slice('id', 'name')}
    json['cards'] = @current_user.cards.map{|card| card.attributes.slice('id', 'name', 'ctype')}
    render(:json => Oj.dump(json))
  end

end