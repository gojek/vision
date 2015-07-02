class ChangeRequest < ActiveRecord::Base
  belongs_to :user
  has_many :testers
  has_many :implementers
  has_many :cabs
  has_many :approvers
  accepts_nested_attributes_for :implementers
  accepts_nested_attributes_for :testers
  accepts_nested_attributes_for :cabs
  accepts_nested_attributes_for :approvers
  validates :change_summary, :priority, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, presence: true
end

