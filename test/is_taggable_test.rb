require File.dirname(__FILE__) + '/test_helper'

Expectations do
  expect Tag do
    Post.new.tags.build
  end

  expect Tagging do
    Post.new.taggings.build
  end

  expect ["something cool", "something else cool"] do
    p = Post.new :tag_list => "something cool, something else cool"
    p.tag_list
  end

  expect ["something cool", "something new"] do
    p = Post.new :tag_list => "something cool, something else cool"
    p.save!
    p.tag_list = "something cool, something new"
    p.save!
    p.tags.reload
    p.instance_variable_set("@tag_list", nil)
    p.tag_list
  end

  expect ["english", "french"] do
    p = Post.new :language_list => "english, french"
    p.save!
    p.tags.reload
    p.instance_variable_set("@language_list", nil)
    p.language_list
  end

  expect ["english", "french"] do
    p = Post.new :language_list => "english, french"
    p.language_list
  end

  expect "english, french" do
    p = Post.new :language_list => "english, french"
    p.language_list.to_s
  end
  
  # added - should clean up strings with arbitrary spaces around commas
  expect ["spaces","should","not","matter"] do
    p = Post.new
    p.tag_list = "spaces,should,  not,matter"
    p.save!
    p.tags.reload
    p.tag_list
  end

  expect 2 do
    p = Post.new :language_list => "english, french"
    p.save!
    p.tags.length
  end
end
