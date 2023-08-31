class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def check_current_user
    if current_user.nil?
      render_202("Unauthorized")
    end
  end

  def render_200(msg, resp = {})
    resp["message"] = msg if msg.present?
    render :json => resp, :status => 200
  end

  def render_201(msg, resp = {})
    resp["message"] = msg if msg.present?
    render :json => resp, :status => 201
  end

  def render_202(msg, resp = {})
    resp["message"] = msg if msg.present?
    render :json => resp, :status => 202
  end

  def render_400(msg, resp = {})
    resp['error'] = msg if msg.present?
    render :json => resp, :status => 400
  end

  def render_404(msg, resp = {})
    resp['error'] = msg if msg.present?
    render :json => resp, :status => 404
  end
end
