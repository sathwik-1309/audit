class SessionController < ApplicationController
    def sign_in
        user = User.find_by_email(filter_params[:email])
        msg = { "token" => user.authentication_token }
        render_200("User signed in", msg)
    end

    private

    def filter_params
        params.permit(:email, :password)
    end
end