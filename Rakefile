# Rakefile for rake        -*- ruby -*-

# Copyright 2003, 2004, 2005 by Jim Weirich (jim@weirichhouse.org)
# All rights reserved.

# This file may be distributed under an MIT style license.  See
# MIT-LICENSE for details.

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end
require 'rake/clean'
require 'rake/rdoctask'

# Prevent OS X from including extended attribute junk in the tar output
ENV['COPY_EXTENDED_ATTRIBUTES_DISABLE'] = 'true'

def announce(msg='')
  STDERR.puts msg
end

# Determine the current version of the software

if `ruby -Ilib ./bin/esk --version` =~ /^([0-9.]+)$/
  CURRENT_VERSION = $1
else
  CURRENT_VERSION = "0.0.0"
end

$package_version = CURRENT_VERSION

# The default task is run if rake is given no explicit arguments.

desc "Default Task"
task :default => :test_all

# Create a task to build the RDOC documentation tree.

rd = Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = 'html'
  rdoc.template = 'doc/jamis.rb'
  rdoc.title    = "Emacs Starter Kit"
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' <<  'Rake -- Ruby Make' 
  rdoc.rdoc_files.include('README', 'MIT-LICENSE', 'TODO', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
}

# ====================================================================
# Create a task that will package the Rake software into distributable
# tar, zip and gem files.

PKG_FILES = FileList[
  '[A-Z]*',
  'bin/**/*', 
  'sitedir/**/*.el',
  'doc/**/*'
]
PKG_FILES.exclude('doc/example/*.o')
PKG_FILES.exclude(%r{doc/example/main$})

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    s.name = 'emacs-starter-kit'
    s.version = $package_version
    s.summary = "Emacs Starter Kit for Rubyist"
    s.description = <<-EOF
      Emacs Starter kit for Rubyists.
    EOF
    s.files = PKG_FILES.to_a
    s.bindir = "bin"                               # Use these for applications.
    s.executables = ["esk"]
    s.default_executable = "esk"
    s.has_rdoc = true
    s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
    s.rdoc_options = rd.options
    s.author = "Jim Weirich"
    s.email = "jim.weirich@gmail.com"
  end

  package_task = Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end

load "publish.rf" if File.exist? "publish.rf"

desc "Make a new release"
task :release, :rel, :reuse, :reltest,
  :needs => [
    :prerelease,
    :clobber,
    :test_all,
    :update_version,
    :package,
    :tag
  ] do
  announce 
  announce "**************************************************************"
  announce "* Release #{$package_version} Complete."
  announce "* Packages ready to upload."
  announce "**************************************************************"
  announce 
end

# Validate that everything is ready to go for a release.
task :prerelease, :rel, :reuse, :reltest do |t, args|
  $package_version = args.rel
  announce 
  announce "**************************************************************"
  announce "* Making RubyGem Release #{$package_version}"
  announce "* (current version #{CURRENT_VERSION})"
  announce "**************************************************************"
  announce  

  # Is a release number supplied?
  unless args.rel
    fail "Usage: rake release[X.Y.Z] [REUSE=tag_suffix]"
  end

  # Is the release different than the current release.
  # (or is REUSE set?)
  if $package_version == CURRENT_VERSION && ! args.reuse
    fail "Current version is #{$package_version}, must specify REUSE=tag_suffix to reuse version"
  end

  # Are all source files checked in?
  if args.reltest
    announce "Release Task Testing, skipping checked-in file test"
  else
    announce "Checking for unchecked-in files..."
    data = `svn st`
    unless data =~ /^$/
      abort "svn status is not clean ... do you have unchecked-in files?"
    end
    announce "No outstanding checkins found ... OK"
  end
end

task :update_version, :rel, :reuse, :reltest,
  :needs => [:prerelease] do |t, args|
  if args.rel == CURRENT_VERSION
    announce "No version change ... skipping version update"
  else
    announce "Updating Rake version to #{args.rel}"
    open("lib/rake.rb") do |rakein|
      open("lib/rake.rb.new", "w") do |rakeout|
	rakein.each do |line|
	  if line =~ /^RAKEVERSION\s*=\s*/
	    rakeout.puts "RAKEVERSION = '#{args.rel}'"
	  else
	    rakeout.puts line
	  end
	end
      end
    end
    mv "lib/rake.rb.new", "lib/rake.rb"
    if args.reltest
      announce "Release Task Testing, skipping commiting of new version"
    else
      sh %{svn commit -m "Updated to version #{args.rel}" lib/rake.rb} # "
    end
  end
end

desc "Tag all the CVS files with the latest release number (REL=x.y.z)"
task :tag, :rel, :reuse, :reltest,
  :needs => [:prerelease] do |t, args|
  reltag = "REL_#{args.rel.gsub(/\./, '_')}"
  reltag << args.reuse.gsub(/\./, '_') if args.reuse
  announce "Tagging Repository with [#{reltag}]"
  if args.reltest
    announce "Release Task Testing, skipping CVS tagging"
  else
    sh %{svn copy svn+ssh://rubyforge.org/var/svn/rake/trunk svn+ssh://rubyforge.org/var/svn/rake/tags/#{reltag} -m 'Commiting release #{reltag}'} ###'
  end
end

desc "Install the jamis RDoc template"
task :install_jamis_template do
  require 'rbconfig'
  dest_dir = File.join(Config::CONFIG['rubylibdir'], "rdoc/generators/template/html")
  fail "Unabled to write to #{dest_dir}" unless File.writable?(dest_dir)
  install "doc/jamis.rb", dest_dir, :verbose => true
end

# Require experimental XForge/Metaproject support.

load 'xforge.rf' if File.exist?('xforge.rf')

desc "Where is the current directory.  This task displays\nthe current rake directory"
task :where_am_i do
  puts Rake.original_dir
end
