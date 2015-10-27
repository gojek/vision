#
class PagesController < ApplicationController
  before_action :signed_in, only: [:index]

  def index
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
  end
  def blank
  end

  def signin
    redirect_to root_path if user_signed_in?
  end

  private

  def signed_in
    redirect_to signin_path unless user_signed_in?
  end
end
