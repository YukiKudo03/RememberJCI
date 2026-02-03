# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      authorize User
      @users = policy_scope(User)
    end

    def show
      @user = User.find(params[:id])
      authorize @user
    end

    def new
      authorize User
      @user = User.new
    end

    def create
      authorize User
      @user = User.new(user_params)
      if @user.save
        UserMailer.welcome(@user).deliver_later
        redirect_to admin_users_path, notice: "ユーザーを作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @user = User.find(params[:id])
      authorize @user
    end

    def update
      @user = User.find(params[:id])
      authorize @user
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "ユーザーを更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      authorize @user
      @user.destroy
      redirect_to admin_users_path, notice: "ユーザーを削除しました"
    end

    def import
      authorize User
      @import_result = nil
    end

    def import_create
      authorize User

      unless params[:file].present?
        @import_result = Users::CsvImportService::Result.new(
          success?: false,
          errors: [ "ファイルを選択してください" ],
          imported_count: 0
        )
        render :import, status: :unprocessable_entity
        return
      end

      @import_result = Users::CsvImportService.import_from_file(params[:file])

      if @import_result.success?
        redirect_to admin_users_path, notice: "#{@import_result.imported_count}件のユーザーをインポートしました"
      else
        render :import, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :name, :password, :role)
    end
  end
end
