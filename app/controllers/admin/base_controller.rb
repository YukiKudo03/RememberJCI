# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

    private

    def render_forbidden
      head :forbidden
    end
  end
end
