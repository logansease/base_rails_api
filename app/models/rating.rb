class Rating < ActiveRecord::Base

  attr_protected

  validates_uniqueness_of :target_id, :scope => [:user_id, :target_type]

  validates :user_id, :presence => true
  validates :target_id, :presence => true

  belongs_to :user
  belongs_to :rated_questions, -> {where(ratings: { target_type: RELATIONSHIP_TYPE_QUESTION})}, :foreign_key => "target_id", :class_name => "Question"


  def target
    if target_type == RELATIONSHIP_TYPE_QUESTION
      Question.find(target_id)
    end
  end

end
