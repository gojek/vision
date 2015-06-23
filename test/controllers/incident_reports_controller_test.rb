require 'test_helper'

class IncidentReportsControllerTest < ActionController::TestCase
  setup do
    @incident_report = incident_reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:incident_reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create incident_report" do
    assert_difference('IncidentReport.count') do
      post :create, incident_report: { current_status: @incident_report.current_status, detection_time: @incident_report.detection_time, how_detected: @incident_report.how_detected, loss_related: @incident_report.loss_related, measurer_status: @incident_report.measurer_status, occurred_reason: @incident_report.occurred_reason, occurrence_time: @incident_report.occurrence_time, overlooked_reason: @incident_report.overlooked_reason, prevent_action: @incident_report.prevent_action, problem_details: @incident_report.problem_details, rank: @incident_report.rank, recovery_action: @incident_report.recovery_action, recovery_time: @incident_report.recovery_time, recurrence_concern: @incident_report.recurrence_concern, service_impact: @incident_report.service_impact, source: @incident_report.source, user_id: @incident_report.user_id }
    end

    assert_redirected_to incident_report_path(assigns(:incident_report))
  end

  test "should show incident_report" do
    get :show, id: @incident_report
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @incident_report
    assert_response :success
  end

  test "should update incident_report" do
    patch :update, id: @incident_report, incident_report: { current_status: @incident_report.current_status, detection_time: @incident_report.detection_time, how_detected: @incident_report.how_detected, loss_related: @incident_report.loss_related, measurer_status: @incident_report.measurer_status, occurred_reason: @incident_report.occurred_reason, occurrence_time: @incident_report.occurrence_time, overlooked_reason: @incident_report.overlooked_reason, prevent_action: @incident_report.prevent_action, problem_details: @incident_report.problem_details, rank: @incident_report.rank, recovery_action: @incident_report.recovery_action, recovery_time: @incident_report.recovery_time, recurrence_concern: @incident_report.recurrence_concern, service_impact: @incident_report.service_impact, source: @incident_report.source, user_id: @incident_report.user_id }
    assert_redirected_to incident_report_path(assigns(:incident_report))
  end

  test "should destroy incident_report" do
    assert_difference('IncidentReport.count', -1) do
      delete :destroy, id: @incident_report
    end

    assert_redirected_to incident_reports_path
  end
end
