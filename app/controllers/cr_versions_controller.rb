#
class CrVersionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document_and_version, only: [:diff, :rollback, :destroy]

  def diff
  end

  def rollback
    # change the current document to the specified version
    # reify gives you the object of this version
    change_request = @version.reify
    change_request.save
    redirect_to edit_change_request_path(change_request)
  end

  def bringback
    version = ChangeRequestVersion.find(params[:id])
    @change_request = version.reify
    @change_request.save
    # Let's remove the version since the document is undeleted
    version.delete
    redirect_to change_requests_path,
                notice: 'The document was successfully brought back!'
  end

  private

  def set_document_and_version
    @change_request = ChangeRequest.find(params[:change_request_id])
    @version = @change_request.versions.find(params[:id])
  end
end
