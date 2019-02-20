#!/usr/bin/rake
require 'pathname'
require 'yaml'
require 'shellwords'

## [ Constants ] ##############################################################

WORKSPACE = 'StyleSource'.freeze
SCHEME_NAME = 'StyleSource'.freeze
RELEASE_CONFIGURATION = 'release'.freeze
MIN_XCODE_VERSION = 10.0

BUILD_DIR = File.absolute_path('./.build')
TARGET_DIR = File.absolute_path('./build')
BIN_NAME = 'StyleSource'.freeze
TEMPLATES_SRC_DIR = 'templates'.freeze

## [ Utils ] ##################################################################

def path(str)
  return nil if str.nil? || str.empty?
  Pathname.new(str)
end

def defaults(args)
  bindir = path(args.bindir) || (Pathname.new(TARGET_DIR) + 'StyleSource/bin')
  fmkdir = path(args.fmkdir) || (bindir + '../lib')
  tpldir = path(args.tpldir) || (bindir + '../templates')
  [bindir, fmkdir, tpldir].map(&:expand_path)
end

## [ Build Tasks ] ############################################################

namespace :cli do
  desc "Build the CLI binary and its frameworks as an app bundle\n" \
       "(in #{BUILD_DIR})"
  task :build, %i[bindir tpldir] do |task, args|
    (bindir, _, tpldir) = defaults(args)
    tpl_rel_path = tpldir.relative_path_from(bindir)

    Utils.print_header 'Building Binary'
    Utils.run(
      %(swift build -c=release),
      task, xcrun: true, formatter: :xcpretty
    )
  end

  desc "Install the binary in $bindir, frameworks in $fmkdir, and templates in $tpldir\n" \
       '(defaults $bindir=./build/StyleSource/bin/, $fmkdir=$bindir/../lib, $tpldir=$bindir/../templates'
  task :install, %i[bindir fmkdir tpldir] => :build do |task, args|
    (bindir, fmkdir, tpldir) = defaults(args)
    generated_bundle_path = "#{BUILD_DIR}/#{RELEASE_CONFIGURATION}"

    Utils.print_header "Installing binary in #{bindir}"
    Utils.run([
                %(mkdir -p "#{bindir}"),
                %(cp -f "#{generated_bundle_path}/StyleSource" "#{bindir}/#{BIN_NAME}")
              ], task, 'copy_binary')
    Utils.print_header "Installing templates in #{tpldir}"
    Utils.run([
                %(mkdir -p "#{tpldir}"),
                %(cp -r "#{TEMPLATES_SRC_DIR}/" "#{tpldir}")
              ], task, 'copy_templates')

    Utils.print_info "Finished installing. Binary is available in: #{bindir}"
  end

  desc "Delete the build directory\n" \
     "(#{BUILD_DIR})"
  task :clean do
    sh %(rm -fr #{BUILD_DIR})
  end
end

task :default => 'cli:build'