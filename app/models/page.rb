# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  content    :text
#

class Page < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :content, :title

  friendly_id :title

  validates :title, :uniqueness => true

end
