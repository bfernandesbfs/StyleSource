#!/usr/bin/rake
require 'pathname'
require 'yaml'
require 'shellwords'

## [ Constants ] ##############################################################

WORKSPACE = 'StyleSource'.freeze
SCHEME_NAME = 'StyleSource'.freeze
CONFIGURATION = 'Debug'.freeze
RELEASE_CONFIGURATION = 'Release'.freeze
POD_NAME = 'StyleSource'.freeze
MIN_XCODE_VERSION = 9.2

BUILD_DIR = File.absolute_path('./build')
BIN_NAME = 'StyleSource'.freeze
TEMPLATES_SRC_DIR = 'templates'.freeze

## [ Utils ] ##################################################################

def path(str)
  return nil if str.nil? || str.empty?
  Pathname.new(str)
end

def defaults(args)
  bindir = path(args.bindir) || (Pathname.new(BUILD_DIR) + 'StyleSource/bin')
  fmkdir = path(args.fmkdir) || (bindir + '../lib')
  tpldir = path(args.tpldir) || (bindir + '../templates')
  [bindir, fmkdir, tpldir].map(&:expand_path)
end


## [ Output compilation ] #####################################################

MODULE_INPUT_PATH = 'Tests/Fixtures/CompilationEnvironment/Modules'.freeze
MODULE_OUTPUT_PATH = 'Tests/Fixtures/CompilationEnvironment'.freeze
SDKS = {
  macosx: 'x86_64-apple-macosx10.13',
  iphoneos: 'arm64-apple-ios11.0',
  watchos: 'armv7k-apple-watchos4.0',
  appletvos: 'arm64-apple-tvos11.0'
}.freeze
TOOLCHAINS = {
  swift3: {
    version: 3,
    module_path: "#{MODULE_OUTPUT_PATH}/swift3",
    toolchain: 'com.apple.dt.toolchain.XcodeDefault'
  },
  swift4: {
    version: 4,
    module_path: "#{MODULE_OUTPUT_PATH}/swift4",
    toolchain: 'com.apple.dt.toolchain.XcodeDefault'
  }
}.freeze

namespace :output do
  desc 'Compile modules'
  task :modules do |task|
    Utils.print_header 'Compile output modules'

    # macOS
    modules = %w[ExtraModule PrefsWindowController]
    modules.each do |m|
      Utils.print_info "Compiling module #{m}… (macos)"
      compile_module(m, :macosx, task)
    end

    # iOS
    modules = %w[ExtraModule LocationPicker SlackTextViewController]
    modules.each do |m|
      Utils.print_info "Compiling module #{m}… (ios)"
      compile_module(m, :iphoneos, task)
    end

    # delete swiftdoc
    Dir.glob("#{MODULE_OUTPUT_PATH}/*/*.swiftdoc").each do |f|
      FileUtils.rm_rf(f)
    end
  end

  desc 'Compile output'
  task :compile => :modules do |task|
    Utils.print_header 'Compiling template output files'

    failures = []
    Dir.glob('Tests/Fixtures/Generated/**/*.swift').each do |f|
      Utils.print_info "Compiling #{f}…\n"
      failures << f unless compile_file(f, task)
    end

    Utils.print_header 'Compilation report'
    if failures.empty?
      Utils.print_info 'All files compiled successfully!'
    else
      Utils.print_error 'The following files failed to compile'
      failures.each { |f| Utils.print_error " - #{f}" }
    end
    exit failures.empty?
  end

  def compile_module(m, sdk, task)
    target = SDKS[sdk]
    subtask = File.basename(m, '.*')
    commands = TOOLCHAINS.map do |_key, toolchain|
      %(--toolchain #{toolchain[:toolchain]} -sdk #{sdk} swiftc -swift-version #{toolchain[:version]} ) +
        %(-emit-module "#{MODULE_INPUT_PATH}/#{m}.swift" -module-name "#{m}" ) +
        %(-emit-module-path "#{toolchain[:module_path]}/#{sdk}" -target "#{target}")
    end

    Utils.run(commands, task, subtask, xcrun: true)
  end

  def toolchain(f)
    if f.include?('swift3')
      TOOLCHAINS[:swift3]
    elsif f.include?('swift4')
      TOOLCHAINS[:swift4]
    end
  end

  def sdks(f)
    if f.include?('iOS')
      [:iphoneos]
    elsif f.include?('macOS')
      [:macosx]
    else
      %i[iphoneos macosx appletvos watchos]
    end
  end

  def files(f)
    if !(f.include?('iOS') || f.include?('macOS'))
      [f]
    elsif f.include?('public-access')
      ["#{MODULE_OUTPUT_PATH}/PublicDefinitions.swift", f]
    else
      ["#{MODULE_OUTPUT_PATH}/Definitions.swift", f]
    end
  end

  def flags(f)
    if f.include?('ignore-target-module-with-extra-module')
      ['-D', 'DEFINE_EXTRA_MODULE_TYPES']
    elsif f.include?('with-extra-module') || f.include?('no-defined-module')
      ['-D', 'DEFINE_NAMESPACED_EXTRA_MODULE_TYPES']
    else
      []
    end
  end

  def compile_file(f, task)
    toolchain = toolchain(f)
    if toolchain.nil?
      puts "Unknown Swift toolchain for file #{f}"
      return true
    end
    sdks = sdks(f)
    files = files(f)
    flags = flags(f)

    commands = sdks.map do |sdk|
      %(--toolchain #{toolchain[:toolchain]} -sdk #{sdk} swiftc -swift-version #{toolchain[:version]} ) +
        %(-typecheck -target #{SDKS[sdk]} -I "#{toolchain[:module_path]}/#{sdk}" #{flags.join(' ')} ) +
        %(-module-name StyleSource #{files.join(' ')})
    end
    subtask = File.basename(f, '.*')

    begin
      Utils.run(commands, task, subtask, xcrun: true)
      return true
    rescue
      Utils.print_error "Failed to compile #{f}!"
      return false
    end
  end
end

## [ Build Tasks ] ############################################################

namespace :cli do
  desc "Build the CLI binary and its frameworks as an app bundle\n" \
       "(in #{BUILD_DIR})"
  task :build, %i[bindir tpldir] do |task, args|
    (bindir, _, tpldir) = defaults(args)
    tpl_rel_path = tpldir.relative_path_from(bindir)

    Utils.print_header 'Building Binary'
    plist_file = (Pathname.new(BUILD_DIR) + "Build/Products/#{RELEASE_CONFIGURATION}/StyleSource.app/Contents/Info.plist").to_s
    Utils.run(
      %(xcodebuild -workspace "#{WORKSPACE}.xcworkspace" -scheme "#{SCHEME_NAME}" -configuration "#{RELEASE_CONFIGURATION}") +
      %( -derivedDataPath "#{BUILD_DIR}" TEMPLATE_PATH="#{tpl_rel_path}") +
      %( STYLESOURCE_OTHER_LDFLAGS="-sectcreate __TEXT __info_plist #{plist_file.shellescape}"),
      task, xcrun: true, formatter: :xcpretty
    )
  end

  desc "Install the binary in $bindir, frameworks in $fmkdir, and templates in $tpldir\n" \
       '(defaults $bindir=./build/StyleSource/bin/, $fmkdir=$bindir/../lib, $tpldir=$bindir/../templates'
  task :install, %i[bindir fmkdir tpldir] => :build do |task, args|
    (bindir, fmkdir, tpldir) = defaults(args)
    generated_bundle_path = "#{BUILD_DIR}/Build/Products/#{RELEASE_CONFIGURATION}/StyleSource.app/Contents"

    Utils.print_header "Installing binary in #{bindir}"
    Utils.run([
                %(mkdir -p "#{bindir}"),
                %(cp -f "#{generated_bundle_path}/MacOS/StyleSource" "#{bindir}/#{BIN_NAME}")
              ], task, 'copy_binary')

    Utils.print_header "Installing frameworks in #{fmkdir}"
    Utils.run([
                %(if [ -d "#{fmkdir}" ]; then rm -rf "#{fmkdir}"; fi),
                %(mkdir -p "#{fmkdir}"),
                %(cp -fR "#{generated_bundle_path}/Frameworks/" "#{fmkdir}")
              ], task, 'copy_frameworks')

    Utils.print_header "Fixing binary's @rpath"
    Utils.run([
                %(install_name_tool -delete_rpath "@executable_path/../Frameworks" "#{bindir}/#{BIN_NAME}"),
                %(install_name_tool -add_rpath "@executable_path/#{fmkdir.relative_path_from(bindir)}" "#{bindir}/#{BIN_NAME}")
              ], task, 'fix_rpath', xcrun: true)

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