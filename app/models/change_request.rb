class ChangeRequest < ActiveRecord::Base
  belongs_to :user
  has_many :testers
  has_many :implementers
  has_many :cabs
  has_many :approvers
  accepts_nested_attributes_for :implementers,
                                    reject_if: proc { |attributes| attributes['name'].blank? || attributes['position'].blank?}
  accepts_nested_attributes_for :testers,
                                    reject_if: proc { |attributes| attributes['name'].blank? || attributes['position'].blank?}
  accepts_nested_attributes_for :cabs,
                                    reject_if: proc { |attributes| attributes['name'].blank? || attributes['position'].blank?}
  accepts_nested_attributes_for :approvers,
                                    reject_if: proc { |attributes| attributes['name'].blank? || attributes['position'].blank?}
  validates :requestor_desc, :priority, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, presence: true
end
