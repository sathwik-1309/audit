class UserController < ApplicationController
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
      render_202("Username not found")
    else
      if user.valid_password?(password)
        render_200("Credentials are valid")
      else
        render_202("Username and Password dont match")
      end
    end
  end

  def create
    attributes = filter_params.slice(:name, :email, :password, :username)
    if User.find_by_username(filter_params[:username]).present?
      render_202("Username already taken") and return
    end
    if User.find_by_email(filter_params[:email]).present?
      render_202("Email already taken") and return
    end
    @user = User.new(attributes)
    if @user.save!
      render_200("User created", {
        "name": @user.name,
        "email": @user.email
      })
    else
      render_404("Some error occured")
    end
  end

  def update
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render_404("Account not found") and return
    end
    @user.assign_attributes(filter_params)
    if @user.save!
      msg = {
        "@user": {
          "name": @user.name,
          "email": @user.email
        }
      }
      render_200("User updated", msg)
    else
      render_404("Some error occured")
    end
  end

  private

  def filter_params
    params.permit(:name, :email, :password, :username)
  end
end
