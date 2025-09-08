# ruby

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

module Critic
  module Functional
    class RailsTest < Critic::Functional::Test
      def setup
        @original_dir = Dir.pwd
        @temp_dir = Dir.mktmpdir
        Dir.chdir(@temp_dir)
        create_default_config_file
        create_rails_config_file
        create_specific_config_files
      end

      def create_default_config_file
        @default_root_dir = File.join(FileUtils.pwd)
        default_dir = File.join(@default_root_dir, 'config', 'configatron')
        FileUtils.mkdir_p(default_dir)
        write_config(File.join(default_dir, 'defaults.rb'), 'configatron.default.defaults.a = 1')
        write_config(File.join(default_dir, 'defaults.rb'), 'configatron.default.defaults.b = 2')
        write_config(File.join(default_dir, 'development.rb'), 'configatron.default.development.c = 3')
        write_config(File.join(default_dir, 'development.rb'), 'configatron.default.development.d = 4')
        write_config(File.join(default_dir, 'test.rb'), 'configatron.default.test.e = 5')
        write_config(File.join(default_dir, 'test.rb'), 'configatron.default.test.f = 6')
      end

      def create_rails_config_file
        @rails_root_dir = File.join(FileUtils.pwd, 'rails_root')
        rails_dir = File.join(@rails_root_dir, 'config', 'configatron')
        FileUtils.mkdir_p(rails_dir)
        write_config(File.join(rails_dir, 'defaults.rb'), 'configatron.rails.defaults.a = 7')
        write_config(File.join(rails_dir, 'defaults.rb'), 'configatron.rails.defaults.b = 8')
        write_config(File.join(rails_dir, 'development.rb'), 'configatron.rails.development.c = 9')
        write_config(File.join(rails_dir, 'development.rb'), 'configatron.rails.development.d = 10')
        write_config(File.join(rails_dir, 'test.rb'), 'configatron.rails.test.e = 11')
        write_config(File.join(rails_dir, 'test.rb'), 'configatron.rails.test.f = 12')
      end

      def create_specific_config_files # rubocop:disable Metrics/AbcSize
        @test_root_dir = File.join(FileUtils.pwd, 'test_root')
        FileUtils.mkdir_p(@test_root_dir)
        write_config(File.join(@test_root_dir, 'defaults.rb'), 'configatron.test_root.defaults.a = 13')
        write_config(File.join(@test_root_dir, 'defaults.rb'), 'configatron.test_root.defaults.b = 14')
        write_config(File.join(@test_root_dir, 'development.rb'), 'configatron.test_root.development.c = 15')
        write_config(File.join(@test_root_dir, 'development.rb'), 'configatron.test_root.development.d = 16')
        write_config(File.join(@test_root_dir, 'test.rb'), 'configatron.test_root.test.e = 17')
        write_config(File.join(@test_root_dir, 'test.rb'), 'configatron.test_root.test.f = 18')
        write_config(File.join(@test_root_dir, 'production.rb'), 'configatron.test_root.production.g = 19')
        write_config(File.join(@test_root_dir, 'production.rb'), 'configatron.test_root.production.h = 20')
      end

      def write_config(path, context)
        File.open(path, 'a') { |f| f.puts context }
      end

      def teardown
        Dir.chdir(@original_dir)
        FileUtils.remove_entry(@temp_dir) if Dir.exist?(@temp_dir)
        Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)
        configatron.reset!
      end

      it 'loads configuration files without Rails' do
        Configatron::Integrations::Rails.init
        assert_equal({ default: { defaults: { a: 1, b: 2 }, development: { c: 3, d: 4 } } }, configatron.to_h)
      end

      it 'loads configuration files with Rails' do
        Object.const_set(:Rails, Module.new)
        ::Rails.stubs(:root).returns(@rails_root_dir)
        ::Rails.stubs(:env).returns('test')
        Configatron::Integrations::Rails.init
        assert_equal({ rails: { defaults: { a: 7, b: 8 }, test: { e: 11, f: 12 } } }, configatron.to_h)
      end

      it 'loads specific configuration files without Rails' do
        Configatron::Integrations::Rails.init(@test_root_dir, 'production')
        assert_equal({ test_root: { defaults: { a: 13, b: 14 }, production: { g: 19, h: 20 } } }, configatron.to_h)
      end

      it 'loads specific configuration files with Rails' do
        Object.const_set(:Rails, Module.new)
        ::Rails.stubs(:root).returns(@rails_root_dir)
        ::Rails.stubs(:env).returns('test')
        Configatron::Integrations::Rails.init(@test_root_dir, 'production')
        assert_equal({ test_root: { defaults: { a: 13, b: 14 }, production: { g: 19, h: 20 } } }, configatron.to_h)
      end
    end
  end
end
