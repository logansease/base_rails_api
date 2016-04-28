class Spot < ActiveRecord::Base

  attr_protected

  has_many :answers, :through => :response_options

  #complex relationship to comments
  has_many :comments, -> { where target_type: RELATIONSHIP_TYPE_SPOT},
           :dependent => :destroy,
           :foreign_key => "target_id",
           :class_name => "Comment"

  has_many :ratings, -> { where target_type: RELATIONSHIP_TYPE_SPOT},
           :dependent => :destroy,
           :foreign_key => "target_id"

  #complex favorites relationships
  has_many :user_relationships, -> { where target_type: RELATIONSHIP_TYPE_SPOT},
           :dependent => :destroy,
           :foreign_key => "target_id",
           :class_name => "Relationship"
  has_many :followers, :through => :user_relationships, :source => :follower

  def rating_score
    ratings.sum(:value)
  end

  def is_user_favorite user_id
    fav = nil
    if user_id
      fav = Relationship.find_by :target_type => RELATIONSHIP_TYPE_SPOT, :user_id => user_id, :target_id => self.id
    end
   fav != nil
  end

end
