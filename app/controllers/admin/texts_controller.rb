# frozen_string_literal: true

module Admin
  class TextsController < BaseController
    before_action :set_text, only: [:show, :edit, :update, :destroy]

    def index
      authorize Text
      @texts = policy_scope(Text)
    end

    def show
      authorize @text
    end

    def new
      authorize Text
      @text = Text.new
    end

    def create
      authorize Text
      @text = Text.new(text_params)
      @text.created_by = current_user

      import_content_from_file if params[:text][:import_file].present?

      if @text.save
        redirect_to admin_texts_path, notice: "テキストを作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @text
    end

    def update
      authorize @text
      if @text.update(text_params)
        redirect_to admin_texts_path, notice: "テキストを更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @text
      @text.destroy
      redirect_to admin_texts_path, notice: "テキストを削除しました"
    end

    private

    def set_text
      @text = Text.find(params[:id])
    end

    def text_params
      params.require(:text).permit(:title, :content, :category, :difficulty)
    end

    def import_content_from_file
      result = Texts::FileImportService.new(params[:text][:import_file]).call
      if result.success?
        @text.content = result.content
      else
        @text.errors.add(:import_file, result.error)
      end
    end
  end
end
