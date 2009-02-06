Gem::Specification.new do |s|
  s.name = "is_taggable"
  s.version = "0.0.1"
  s.date = "2009-02-04"
  s.summary = "tagging that isn't ugly"
  s.email = "gnutse@gmail.com"
  s.homepage = "http://github.com/gnugeek/is_taggable/"
  s.description = "Extends activerecord to make models taggable"
  s.has_rdoc = true
  s.authors = ["giraffesoft,Karmi,Brian Knox"]
  s.files = [
    "init.rb",
    "README.rdoc",
    "CHANGELOG",
    "lib/is_taggable.rb",
    "lib/tagging.rb",
    "lib/tag.rb",
    "generators/is_taggable/is_taggable_generator.rb",
    "generators/is_taggable/USAGE",
    "generators/is_taggable/templates/autocomplete.js.erb",
    "generators/is_taggable/templates/migration.rb",
    "generators/is_taggable/templates/taggable_controller.rb",
    "generators/is_taggable/templates/taggable_helper.rb"
  ]
  s.test_files = [
    "test/is_taggable_test.rb",
    "test/tagging_test.rb",
    "test/tag_test.rb",
    "test/test_helper.rb"
  ]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc","CHANGELOG"]
end
