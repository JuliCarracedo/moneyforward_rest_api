class UsersController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :authenticate_basic, only: %i[show update close]
  def signup
    if User.find_by_user_id(params[:user_id])
      return render json: {
        "message": "Account creation failed",
        "cause": "Already same user_id is used"
      }, status: :bad_request
    end

    @user = User.new(user_id: params[:user_id],
                    password: params[:password],
                    nickname: params[:user_id])

    if @user.save
      render json: {
        "message": "Account successfully created",
        "user": {
          "user_id": @user.user_id,
          "nickname": @user.nickname
        }
      }, status: :ok
    else
      render json: {
        "message": "Account creation failed",
        "cause": @user.errors.first.message
        }, status: :bad_request
    end
  end

  def show
    @user = User.find_by_user_id(params[:id])

    if @authorized
      unless @user
        return render json: {
                            "message": "No user found"
                          }, status: :not_found
      end

      response = {
                  "message": "User details by user_id",
                  "user": {
                    "user_id": @user.user_id,
                    "nickname": @user.nickname
                  }
                }
      response["user"].merge!("comment": @user.comment) unless @user.comment.nil?

      render json: response, status: :ok
    else
      render json:  {
                      "message": "Authentication failed"
                    }, status: 401
    end
  end

  def update
    @user = User.find_by_user_id(params[:id])

    if @authorized
      unless @user
        return render json: {
                              "message": "No user found"
                            }, status: :not_found
      end

      unless @user.user_id == @current_username
        return render json: {
                              "message": "No permission for update"
                            }, status: 403
      end

      if params[:user_id].presence || params[:password].presence
        return render json: {
                              "message": "User updation failed",
                              "cause": "Not updatable user_id and password"
                            }, status: :bad_request
      end

      new_user_params = {
        comment: params[:comment].presence,
        nickname: params[:nickname].presence
      }

      if new_user_params[:comment].nil? && new_user_params[:nickname].nil?
        return render json: {
                              "message": "User updation failed",
                              "cause": "Required nickname or comment"
                            }, status: :bad_request
      end

      if new_user_params[:nickname].length > 29 || new_user_params[:comment].length > 99
        return render json: {
                              "message": "User updation failed",
                              "cause": "Input length is incorrect"
                            }, status: :bad_request
      end


      if @user.update(new_user_params)
        render json: {
                    "message": "User successfully updated",
                    "user": {
                      "user_id": @user.user_id,
                      "nickname": @user.nickname,
                      "comment": @user.comment
                    }
                  }, status: :ok
      else
        render json: {
                    "message": "User successfully updated",
                    "user": {
                      "user_id": @user.user_id,
                      "nickname": @user.nickname,
                      "comment": @user.comment
                    }
                  }, status: :ok
      end
    else
      render json:  {
                      "message": "Authentication failed"
                    }, status: 401
    end
  end

  def close
    if @authorized
      @current_user.destroy
      render json: {
          "message": "Account and user successfully removed"
        }, status: :ok

    else
      render json: {
        "message": "Authentication failed"
      }, status: 401
    end
  end

  private

  def authenticate_basic
    authenticate_with_http_basic do |username, password|
      @current_username = username
      @current_user = User.find_by_user_id(username)
      @authorized = @current_user&.password == password
    end
  end
end

