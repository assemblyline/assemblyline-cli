require "assemblyline/cli/version"
require "thor"

module Assemblyline
  class CLI < Thor
    desc "build GIT_URL or PATH", "Build an assemblyline project from a git url or path"
    option :debug, type: :boolean, default: false, desc: "start assemblyline-builder with a tty"
    option :push, type: :boolean, default: false, desc: "push the built image to docker repo"
    option :ref, type: :string, desc: "merge this ref into master before building"
    option :dev, type: :string, desc: "use a local dev checkout of assemblyline-builder", banner: "PATH"
    def build(url_or_path)
      init_local_mount url_or_path
      exec "docker run --rm #{bind_mounts} #{env_flags} #{debug_flags} #{dev_mount} #{local_mount} #{assemblyline_builder} bin/build #{build_command(url_or_path)}" # rubocop:disable Metrics/LineLength
    end

    desc "update", "update assemblyline"
    def update
      fail unless system "docker pull #{assemblyline_builder}"
      exec "gem install assemblyline-cli"
    end

    map "-v" => "version", "--version" => "version"
    desc "version", "print the current version"
    def version
      puts CLI_VERSION
    end

    private

    attr_reader :local_mount

    def build_command(url_or_path)
      if local_mount
        "local_build #{push}#{sha}"
      else
        "build #{push}#{url_or_path} #{options[:ref]}"
      end
    end

    def push
      return unless options[:push]
      "--push "
    end

    def sha
      branch_tip == "" ? tip : branch_tip
    end

    def tip
      `git rev-parse HEAD`.chomp
    end

    def branch_tip
      `git rev-parse #{ENV["branch"]}`.chomp
    end

    def init_local_mount(path)
      return unless dir?(path)
      @local_mount = "-v #{File.expand_path(path, Dir.pwd)}:/usr/assemblyline/local"
    end

    def dir?(path)
      File.directory?(File.expand_path(path, Dir.pwd))
    end

    def debug_flags
      return unless options[:debug] || $stdout.isatty
      "-ti"
    end

    def dev_mount
      return unless options[:dev]
      "-v #{File.expand_path(options[:dev], Dir.pwd)}:/usr/src"
    end

    def bind_mounts
      "-v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock"
    end

    def assemblyline_builder
      "quay.io/assemblyline/builder:latest"
    end

    def env_flags
      Env.new.to_flags
    end

    class Env
      def to_flags
        to_hash.map { |var, val| "-e #{var}=#{val}" }.join(" ")
      end

      def to_hash
        {
          "SSH_KEY" => ssh_key,
          "DOCKERCFG" => dockercfg,
          "JSPM_GITHUB_TOKEN" => ENV["JSPM_GITHUB_TOKEN"],
          "CI" => ci?,
          "CI_MASTER" => ci_master?,
          "BUILD_URL" => build_url,
          "GIT_URL" => git_url,
          "GITHUB_ACCESS_TOKEN" => ENV["GITHUB_ACCESS_TOKEN"],
        }.reject { |_, v| v.nil? }
      end

      private

      def ssh_key
        key = File.read(key_path) if key_path
        key.dump if key
      end

      def key_path
        %w(id_rsa id_dsa).map { |private_key| ssh_key_path(private_key) }.detect { |path| File.exist? path }
      end

      def ssh_key_path(key)
        File.join(ENV["HOME"], ".ssh/#{key}")
      end

      def dockercfg
        cfg = ENV["DOCKERCFG"]
        [".dockercfg", ".docker/config.json"].each do |cfg_path|
          path = File.join(Dir.home, cfg_path)
          next unless File.exist? path
          cfg ||= File.read(path)
        end
        return unless cfg
        cfg.gsub("\n", "").gsub("\t", "").dump
      end

      def ci?
        %w(CI CONTINUOUS_INTEGRATION TDDIUM TRAVIS BUILD_ID JENKINS_URL CIRCLECI).each do |var|
          return true if ENV[var]
        end
        nil
      end

      def ci_master?
        return true if ENV["GIT_BRANCH"] == "origin/master"
        return true if ENV["CI_MASTER"]
      end

      def build_url
        ENV["BUILD_URL"]
      end

      def git_url
        u = `git ls-remote --get-url origin`.chomp
        u.empty? ? nil : u
      end
    end
  end
end
