require 'test_helper'

class ChangeRequestsControllerTest < ActionController::TestCase
  setup do
    @change_request = change_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:change_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create change_request" do
    assert_difference('ChangeRequest.count') do
      post :create, change_request: { analysis: @change_request.analysis, backup: @change_request.backup, business_justification: @change_request.business_justification, category: @change_request.category, change_requirement: @change_request.change_requirement, design: @change_request.design, grace_period_end: @change_request.grace_period_end, grace_period_notes: @change_request.grace_period_notes, grace_period_starts: @change_request.grace_period_starts, impact: @change_request.impact, implementation_notes: @change_request.implementation_notes, note: @change_request.note, planned_completion: @change_request.planned_completion, priority: @change_request.priority, requestor_desc: @change_request.requestor_desc, requestor_position: @change_request.requestor_position, restore: @change_request.restore, schedule_change_date: @change_request.schedule_change_date, scope: @change_request.scope, solution: @change_request.solution, testing_environment_available: @change_request.testing_environment_available, testing_notes: @change_request.testing_notes, testing_procedure: @change_request.testing_procedure, type: @change_request.type, user_id: @change_request.user_id }
    end

    assert_redirected_to change_request_path(assigns(:change_request))
  end

  test "should show change_request" do
    get :show, id: @change_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @change_request
    assert_response :success
  end

  test "should update change_request" do
    patch :update, id: @change_request, change_request: { analysis: @change_request.analysis, backup: @change_request.backup, business_justification: @change_request.business_justification, category: @change_request.category, change_requirement: @change_request.change_requirement, design: @change_request.design, grace_period_end: @change_request.grace_period_end, grace_period_notes: @change_request.grace_period_notes, grace_period_starts: @change_request.grace_period_starts, impact: @change_request.impact, implementation_notes: @change_request.implementation_notes, note: @change_request.note, planned_completion: @change_request.planned_completion, priority: @change_request.priority, requestor_desc: @change_request.requestor_desc, requestor_position: @change_request.requestor_position, restore: @change_request.restore, schedule_change_date: @change_request.schedule_change_date, scope: @change_request.scope, solution: @change_request.solution, testing_environment_available: @change_request.testing_environment_available, testing_notes: @change_request.testing_notes, testing_procedure: @change_request.testing_procedure, type: @change_request.type, user_id: @change_request.user_id }
    assert_redirected_to change_request_path(assigns(:change_request))
  end

  test "should destroy change_request" do
    assert_difference('ChangeRequest.count', -1) do
      delete :destroy, id: @change_request
    end

    assert_redirected_to change_requests_path
  end
end
