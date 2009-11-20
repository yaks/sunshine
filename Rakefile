# -*- ruby -*-
require 'rubygems'
require 'hoe'
require 'rake'
require 'rake/testtask'

task :manifest do
  manifest_file = "Manifest.txt"

  gem_files = record_files do |f|
    next if f =~ /^(tmp|pkg)/
    puts(f)
    true
  end

  gem_files.push(manifest_file)
  gem_files = gem_files.uniq.sort.join("\n")

  File.open(manifest_file, "w+") do |file|
    file.write gem_files
  end
end

def record_files(path="*", file_arr=[], &block)
  Dir[path].each do |child_path|
    if File.file?(child_path)
      next if block_given? && !yield(child_path)
      file_arr << child_path
    end
    record_files(child_path+"/*", file_arr, &block) if File.directory?(child_path)
  end
  return file_arr
end

Hoe.spec 'sunshine' do |p|
  developer('Jeremie Castagna', 'jcastagna@atti.com')
  self.extra_deps = [['rainbow', '>= 1.0.4']]
end

# vim: syntax=Ruby

