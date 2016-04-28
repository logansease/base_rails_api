# == Schema Information
#
# Table name: relationships
#
#  id                :integer         not null, primary key
#  relationship_type :string(255)
#  follower_id       :integer
#  followed_id       :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

class Relationship < ActiveRecord::Base
  attr_protected

  validates_uniqueness_of :target_id, :scope => [:user_id, :target_type]
  validates :user_id, :presence => true
  validates :target_id, :presence => true
  validates :target_type, :presence => true

  belongs_to :follower, :foreign_key => "user_id", :class_name => "User"
  belongs_to :followed_questions, -> {where(relationships: { target_type: RELATIONSHIP_TYPE_QUESTION })}, :foreign_key => "target_id", :class_name => "Question"

  def target
    if target_type == RELATIONSHIP_TYPE_QUESTION
      Question.find(target_id)
    end
  end

end