class Rating < ActiveRecord::Base

  attr_protected

  validates_uniqueness_of :target_id, :scope => [:user_id, :target_type]

  validates :user_id, :presence => true
  validates :target_id, :presence => true

  belongs_to :user
  belongs_to :rated_spots, -> {where(ratings: { target_type: RELATIONSHIP_TYPE_SPOT})}, :foreign_key => "target_id", :class_name => "Spot"


  def target
    if target_type == RELATIONSHIP_TYPE_SPOT
      Spot.find(target_id)
    end
  end

end
