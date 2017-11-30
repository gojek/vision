class CommentsController < ApplicationController
  before_action :authenticate_user!
  require 'slack_notif.rb'

  def create
    @cr = ChangeRequest.find(params[:change_request_id])
    @comment = @cr.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        Notifier.cr_notify(current_user, @cr, 'comment_cr')
        #SlackNotif.new.notify_new_comment @comment
        format.html { redirect_to @cr}
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def hide_unhide
    @cr = ChangeRequest.find(params[:change_request_id])
    permitted = params.permit(:type, :comment_id, :change_request_id)
    # 2 available type, hide and unhide
    type = permitted[:type]
    comment = Comment.find(permitted[:comment_id])
    comment.hide = (type == 'hide')
    comment.save
    render json: comment
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:body, :change_request_id, :user_id)
    end
end
