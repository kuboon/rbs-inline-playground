#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates gem_bundle.js by reading Ruby source files from installed gems.
# Usage: bundle exec ruby build_gem_bundle.rb

require "json"
require "bundler/setup"

GEMS = %w[rbs rbs-inline].freeze

bundle = {}

GEMS.each do |gem_name|
  spec = Gem::Specification.find_by_name(gem_name)
  lib_dir = File.join(spec.gem_dir, "lib")

  files = {}
  Dir.glob("#{lib_dir}/**/*.rb").sort.each do |path|
    relative = path.delete_prefix("#{lib_dir}/")
    files[relative] = File.read(path)
  end

  bundle[gem_name] = files
end

output = +"// Auto-generated gem bundle\nconst GEM_BUNDLE = "
output << JSON.generate(bundle)
output << ";\n"

File.write("gem_bundle.js", output)
puts "Generated gem_bundle.js (#{File.size("gem_bundle.js")} bytes)"
