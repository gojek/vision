class CommentsController < ApplicationController
  before_action :authenticate_user!
  require 'mentioner.rb'
  #before_action :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments
  # GET /comments.json


  # POST /comments
  # POST /comments.json
  def create
    @cr = ChangeRequest.find(params[:change_request_id])
    @comment = @cr.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        Notifier.cr_notify(current_user, @cr, 'comment_cr')

        # Placeholder content for slack notification
        mentionees =  Mentioner.process_mentions(@comment)
        mentionees.each do |mtn|
          puts mtn.name
        end

        format.html { redirect_to @cr}
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
=begin
 def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @cr = ChangeRequest.find(params[:change_request_id])
    @comment = @cr.comments.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @cr, notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
=end
  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_comment
      #@comment = Comment.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:body, :change_request_id, :user_id)
    end
end
