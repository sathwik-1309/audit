class UserController < ApplicationController
before_action :set_current_user

  def index
    arr = []
    users = User.all
    users.each do |user|
      arr << {
        "name" => user.name,
        "id" => user.id
      }
    end
    render(:json => arr)
  end

  def check
    email = params[:email]
    password = params[:password]
    user = User.find_by(email: email)
    if user.nil?
      render_202("Email id not found")
    else
      if user.valid_password?(password)
        render_200("Credentials are valid")
      else
        render_202("Email id and Password dont match")
      end
    end
  end

  def create
    attributes = filter_params.slice(:name, :email, :password)
    if User.find_by_email(filter_params[:email]).present?
      render_202("Email already taken") and return
    end
    @user = User.new(attributes)
    begin
      @user.save!
      render_200("User created", {
        "name": @user.name,
        "email": @user.email
      })
    rescue StandardError => ex
      render_202(ex.message)
    end
  end

  def update
    unless @current_user.present?
      render_400("Unauthorized, Please sign in") and return
    end
    @user = @current_user
    @user.assign_attributes(filter_params)
    begin
      @user.save!
      msg = {
        "@user": {
          "name": @user.name,
          "email": @user.email
        }
      }
      render_200("User updated", msg)
    rescue StandardError => ex
      render_404(ex.message)
    end
  end

  private

  def filter_params
    params.permit(:name, :email, :password, :theme)
  end
end
