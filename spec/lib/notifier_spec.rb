require 'spec_helper'
require 'notifier'

describe Notifier do
  let(:user) {FactoryGirl.create(:user)}
  let(:change_request) {FactoryGirl.create(:change_request, user: user)}
  let(:incident_report) {FactoryGirl.create(:incident_report, user: user)}
  let(:message) {['new_cr', 'update_cr' , 'cr_approved' ,'cr_rejected', 'cr_final_rejected', 'cr_cancelled' , 'cr_scheduled', 'cr_deployed' , 'cr_closed' , 'cr_rollbacked' , 'comment_cr' ].sample}
  let(:message_ir) {['new_ir', 'resolved_ir'].sample}
  describe "Notifier.cr_notify" do

    it 'should send notification to the collaborators when a change request is made' do
      expect{Notifier.cr_notify(user, change_request, message)}.to change{change_request.collaborators.first.notifications.cr.count}.by(1)
    end

    it 'should send notification to the approvers when a change request is made' do
      expect{Notifier.cr_notify(user, change_request, message)}.to change{change_request.approvals.first.user.notifications.cr.count}.by(1)
    end

    it 'should send notification to the release managers when a change request is made' do
      rm = FactoryGirl.create(:release_manager)
      expect{Notifier.cr_notify(user, change_request, message)}.to change{User.where(role: 'release_manager').first.notifications.cr.count}.by(1)
    end

    it 'should NOT send notification to the requestor when a change request is made' do
      expect{Notifier.cr_notify(user, change_request, message)}.to_not change{change_request.user.notifications.cr.count}.by(1)
    end
  end

  describe "Notifier.ir_notify" do
    it 'should send notification to all users when an incident report is made' do
      requestor = FactoryGirl.create(:user)
      approver = FactoryGirl.create(:approver)
      rm = FactoryGirl.create(:release_manager)
      admin = FactoryGirl.create(:admin)
      User.all.each do |user|
        expect{Notifier.ir_notify(user, incident_report, message_ir)}.to change{user.notifications.ir.count}.by(1)
      end
    end
  end

  describe "Notifier.cr_read" do
    it 'should change the change request notification read attribute to true' do
      notification = FactoryGirl.create(:notification, user: user, change_request: change_request, read: false)
      Notifier.cr_read(user, change_request)
      notification.reload
      expect(notification.read).to eq true
    end
  end

  describe "Notifier.ir_read" do
    it 'should change the incident report notification read attribute to true' do
      notification = FactoryGirl.create(:notification, user: user, incident_report: incident_report, read: false)
      Notifier.ir_read(user, incident_report)
      notification.reload
      expect(notification.read).to eq true
    end

  end

  describe "Notifier.mark_all_as_read" do
    it 'should change all notification read attribute to true' do
      notif_cr = FactoryGirl.create(:notification, user: user, change_request: change_request, read: false)
      notif_ir = FactoryGirl.create(:notification, user: user, incident_report: incident_report, read: false)
      Notifier.mark_all_as_read(user)
      notif_cr.reload
      notif_ir.reload
      expect(notif_cr.read).to eq true
      expect(notif_ir.read).to eq true
    end

  end
end
