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
        render_200("Credentials are valid", {"auth_token" => user.authentication_token})
      else
        render_202("Email id and Password dont match")
      end
    end
  end

  def create
    name = Util.processed_name(filter_params[:name])
    attributes = filter_params.slice(:email, :password)
    attributes[:name] = name
    if User.find_by_email(filter_params[:email]).present?
      render_202("Email already taken") and return
    end
    @user = User.new(attributes)
    begin
      @user.save!
      LazyWorker.perform_async("send_welcome_email", {"name" => @user.name, "email"=> @user.email })
      LazyWorker.perform_async("send_admin_new_user_mail", {"name" => @user.name })
      render_200("User created", {
        "name": @user.name,
        "email": @user.email,
        "auth_token": @user.authentication_token
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
    begin
      if params[:image].present?
        @user.upload(params[:image])
      end
      @user.assign_attributes(filter_params.slice(:name, :email, :password, :app_theme))
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

  def send_otp
    @user = User.find_by_email(filter_params[:email])
    if @user.nil?
      render_202("No user with this email") and return
    end
    @user.send_reset_password_otp
    render_200("Otp sent to email")
  end

  def otp_match
    @user = User.find_by_email(filter_params[:email])
    if @user.nil?
      render_202("No user with this email") and return
    end
    if @user.meta['reset_password_otp'].include? filter_params[:otp].to_i
      @user.meta['reset_password_otp'] = []
      begin
        @user.save!
        msg = { "user_id"=> @user.id }
        render_200("Password Reset", msg)
      rescue StandardError => ex
        render_202(ex.message)
      end
    else
      render_202("invalid OTP")
    end
  end

  def reset_password
    @user = User.find_by_id(filter_params[:user_id])
    if @user.nil?
      render_202("user not found") and return
    end
    @user.password = filter_params[:password]
    begin
      @user.save!
      render_200("Password reset for #{@user.name}")
    rescue StandardError => ex
      render_202(ex.message)
    end
  end

  def settings
    json = {}
    unless @current_user.present?
      render_400("Unauthorized, Please sign in") and return
    end
    json['user_details'] = @current_user.attributes
    render(:json => json)
  end

  private

  def filter_params
    params.permit(:name, :email, :password, :theme, :otp, :user_id, :app_theme)
  end
end
