class ChangeRequest < ActiveRecord::Base
  belongs_to :user
  has_many :testers
  has_many :implementers
  has_many :cabs
  has_many :approvers
  has_many :comments
  accepts_nested_attributes_for :implementers, :allow_destroy => true
  accepts_nested_attributes_for :testers, :allow_destroy => true
  accepts_nested_attributes_for :cabs, :allow_destroy => true
  accepts_nested_attributes_for :approvers, :allow_destroy => true
  validates :change_summary, :priority, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :requestor_name, presence: true
end

