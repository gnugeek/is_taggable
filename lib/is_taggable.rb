path = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << path unless $LOAD_PATH.include?(path)
require 'tag'
require 'tagging'

module IsTaggable
  class TagList < Array
    def to_s
      join(', ')
    end
  end

  module ActiveRecordExtension
    def is_taggable(*kinds)
      class_inheritable_accessor :tag_kinds
      self.tag_kinds = kinds.map(&:to_s).map(&:singularize)
      self.tag_kinds << :tag if kinds.empty?

      include IsTaggable::TaggableMethods
    end
  end

  module TaggableMethods
    def self.included(klass)
      klass.class_eval do
        include IsTaggable::TaggableMethods::InstanceMethods

        has_many   :taggings, :as      => :taggable
        has_many   :tags,     :through => :taggings
        after_save :save_tags

        tag_kinds.each do |k|
          define_method("#{k}_list")  { get_tag_list(k) }
          define_method("#{k}_list=") { |new_list| set_tag_list(k, new_list) }
        end
        
        # Find all records tagged with a +'tag'+ or ['tag one', 'tag two']
        # Pass either String for single tag or Array for multiple tags
        # TODO : Add option all x any
        def self.find_all_tagged_with(tag_or_tags, conditions=[])
          return [] if tag_or_tags.nil? || tag_or_tags.empty?
          case tag_or_tags
          when Array, IsTaggable::TagList
            all(:include => ['tags', 'taggings'], :conditions => conditions ).select { |record| tag_or_tags.all? { |tag| record.tags.map(&:name).map(&:upcase).include?(tag.upcase) } } || []
          else
            all(:include => ['tags', 'taggings'], :conditions => conditions).select { |record| record.tags.map(&:name).map(&:upcase).include?(tag_or_tags.upcase)  } || []
          end
        end
        
        def self.find_all_ids_tagged_with(tag_or_tags, conditions=[])
          find_all_tagged_with(tag_or_tags, conditions).map(&:id)
        end
        
        # Find all records tagged with the same tags as current object,
        # *excluding* the current object (for things like "Related articles")
        # TODO : Add option all x any
        # TODO : Remove hardcoded +tag_list+ kind of tags, could be any kind
        def find_tagged_alike
          return [] if self.tags.empty?
          self.class.all(:include => ['tags', 'taggings'],
                         :conditions => ["id != '?'", self.id]).
                         select { |record| self.tag_list.all? { |tag| record.tags.map(&:name).include?(tag) } } || []
        end

      end
    end

    module InstanceMethods
      def set_tag_list(kind, list)
        list.gsub!(/ *, */,',') unless list.is_a?(Array)
        tag_list = TagList.new(list.is_a?(Array) ? list : list.split(','))
        instance_variable_set(tag_list_name_for_kind(kind), tag_list)
      end

      def get_tag_list(kind)
        set_tag_list(kind, tags.of_kind(kind).map(&:name)) if tag_list_instance_variable(kind).nil?
        tag_list_instance_variable(kind)
      end

      protected
        def tag_list_name_for_kind(kind)
          "@#{kind}_list"
        end
        
        def tag_list_instance_variable(kind)
          instance_variable_get(tag_list_name_for_kind(kind))
        end

        def save_tags
          tag_kinds.each do |tag_kind|
            delete_unused_tags(tag_kind)
            add_new_tags(tag_kind)
          end

          taggings.each(&:save)
        end

        def delete_unused_tags(tag_kind)
          tags.of_kind(tag_kind).each { |t| tags.delete(t) unless get_tag_list(tag_kind).include?(t.name) }
        end

        def add_new_tags(tag_kind)
          tag_names = tags.of_kind(tag_kind).map(&:name)
          get_tag_list(tag_kind).each do |tag_name| 
            tags << Tag.find_or_initialize_with_name_like_and_kind(tag_name, tag_kind) unless tag_names.include?(tag_name)
          end
        end
    end
  end
end

ActiveRecord::Base.send(:extend, IsTaggable::ActiveRecordExtension)
