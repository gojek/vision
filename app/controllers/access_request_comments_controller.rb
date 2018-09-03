class AccessRequestCommentsController < ApplicationController
  before_action :authenticate_user!
  require 'slack_notif.rb' 

  def create
    @ar = AccessRequest.find(params[:access_request_id])
    @access_request_comment = @ar.access_request_comments.new(access_request_comment_params)
    @access_request_comment.user = current_user

    respond_to do |format|
      if @access_request_comment.save
        Notifier.ar_notify(current_user, @ar, 'comment_ar')
        SlackNotif.new.notify_new_ar_comment @access_request_comment
        format.html { redirect_to @ar}
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end

  end

  def hide_unhide
    @ar = AccessRequest.find(params[:access_request_id])
    permitted = params.permit(:type, :access_request_comment_id, :access_request_id)
    # 2 available type, hide and unhide
    type = permitted[:type]
    access_request_comment = AccessRequestComment.find(permitted[:access_request_comment_id])
    access_request_comment.hide = (type == 'hide')
    access_request_comment.save
    render json: access_request_comment
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def access_request_comment_params
      params.require(:access_request_comment).permit(:body, :access_request_id, :user_id)
  end
end
