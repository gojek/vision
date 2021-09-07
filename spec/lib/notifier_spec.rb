require 'rails_helper'
require 'notifier'

describe Notifier do
  let(:user) {FactoryBot.create(:user)}
  let(:change_request) {FactoryBot.create(:change_request, user: user)}
  let(:incident_report) {FactoryBot.create(:incident_report, user: user)}
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
      rm = FactoryBot.create(:release_manager)
      expect{Notifier.cr_notify(user, change_request, message)}.to change{User.where(role: 'release_manager').first.notifications.cr.count}.by(1)
    end

    it 'should NOT send notification to the requestor when a change request is made' do
      Notifier.cr_notify(user, change_request, message)
      latest_count = change_request.user.notifications.count
      expect(change_request.user.notifications.count).to eq(latest_count)
    end
  end

  describe "Notifier.ir_notify" do
    it 'should send notification to all users when an incident report is made' do
      requestor = FactoryBot.create(:user)
      approver = FactoryBot.create(:approver)
      rm = FactoryBot.create(:release_manager)
      admin = FactoryBot.create(:admin)
      User.all.each do |user|
        expect{Notifier.ir_notify(user, incident_report, message_ir)}.to change{user.notifications.ir.count}.by(1)
      end
    end
  end

  describe "Notifier.cr_read" do
    it 'should delete the specified change request notification' do
      notification = FactoryBot.create(:notification, user: user, change_request: change_request)
      expect(user.notifications.cr.count).to eq 1
      Notifier.cr_read(user, change_request)
      expect(user.notifications.cr.count).to eq 0
    end
  end

  describe "Notifier.ir_read" do
    it 'should delete the specified incident report notification' do
      notification = FactoryBot.create(:notification, user: user, incident_report: incident_report)
      expect(user.notifications.ir.count).to eq 1
      Notifier.ir_read(user, incident_report)
      expect(user.notifications.ir.count).to eq 0
    end

  end

  describe "Notifier.mark_all_as_read" do
    it 'should delete the current user all notifications' do
      notif_cr = FactoryBot.create(:notification, user: user, change_request: change_request)
      notif_ir = FactoryBot.create(:notification, user: user, incident_report: incident_report)
      expect(user.notifications.count).to eq 2
      Notifier.mark_all_as_read(user)
      expect(user.notifications.count).to eq 0
    end

  end
end
