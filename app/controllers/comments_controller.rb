class CommentsController < ApplicationController
  before_action :authenticate_user!
  require 'mentioner.rb'
  require 'slack_notif.rb'

  def create
    @cr = ChangeRequest.find(params[:change_request_id])
    @comment = @cr.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        Notifier.cr_notify(current_user, @cr, 'comment_cr')
        # Placeholder content for slack notification
        mentionees =  Mentioner.process_mentions(@comment)
        if !mentionees.nil?
          link = url_for @cr
          SlackNotif.notif_comment_mention @comment, mentionees, link
        end
        format.html { redirect_to @cr}
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:body, :change_request_id, :user_id)
    end
end
