class Comment < ActiveRecord::Base

  attr_protected

  validates :user_id, :presence => true
  validates :target_id, :presence => true

  belongs_to :user
  belongs_to :spot_comments, -> {where(comments: { target_type: RELATIONSHIP_TYPE_SPOT })}, :foreign_key => "target_id", :class_name => "Spot"

  has_many :ratings, -> { where target_type: RELATIONSHIP_TYPE_COMMENT},
           :dependent => :destroy,
           :foreign_key => "target_id"

  default_scope { order('created_at DESC') }

  def target
    if target_type == RELATIONSHIP_TYPE_SPOT
      Spot.find(target_id)
    end
  end

end
