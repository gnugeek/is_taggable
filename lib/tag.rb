class Tag < ActiveRecord::Base
  class << self
    def find_or_initialize_with_name_like_and_kind(name, kind)
      with_name_like_and_kind(name, kind).first || new(:name => name, :kind => kind)
    end
  end

  has_many :taggings

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :kind

  named_scope :with_name_like_and_kind, lambda { |name, kind| { :conditions => ["name like ? AND kind = ?", name, kind] } }
  named_scope :of_kind,                 lambda { |kind| { :conditions => {:kind => kind} } }
  named_scope :unique_by_name_for_kind,  lambda { |kind| { :conditions => {:kind => kind}, :group => 'id,name,kind,created_at,updated_at' } }
  
  def self.unique_tag_list_by_kind(kind)
    unique_by_name_for_kind('available_service').map(&:name)
  end
end
