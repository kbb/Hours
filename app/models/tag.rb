# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  slug       :string(255)
#

class Tag < ActiveRecord::Base
  attr_reader :total_hours
  include Sluggable

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }

  has_many :taggings
  has_many :entries, through: :taggings
  has_many :projects, -> { uniq }, through: :entries
  has_many :users, -> { uniq }, through: :entries
  belongs_to :project

  def self.list
    Tag.order(:name).pluck(:name)
  end

  private

  def slug_source
    name
  end
end
