require 'assemblyline/cli/version'
require 'thor'

module Assemblyline
  class CLI < Thor
    desc 'build URL (REF)', 'Build an assemblyline project from a git url and optionaly merge REF into master'
    option :debug, type: :boolean
    def build(url, ref = nil)
      exec "docker run --rm #{bind_mounts} #{env_flags} #{debug_flags} #{assemblyline_builder} bin/build #{url} #{ref}"
    end

    desc 'update', 'update assemblyline'
    def update
      fail unless system "docker pull #{assemblyline_builder}"
      exec 'gem install assemblyline-cli'
    end

    map '-v' => 'version', '--version' => 'version'
    desc 'version', 'print the current version'
    def version
      puts CLI_VERSION
    end

    private

    def debug_flags
      return unless options[:debug]
      "-v #{Dir.pwd}:/usr/src -ti"
    end

    def env_flags
      env.map { |var, val| "-e #{var}=#{val}" }.join(' ')
    end

    def env
      {
        'SSH_KEY' => ssh_key,
        'DOCKERCFG' => dockercfg,
      }
    end

    def bind_mounts
      '-v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock'
    end

    def assemblyline_builder
      'quay.io/assemblyline/builder:latest'
    end

    def ssh_key
      key = File.read(key_path)
      fail 'SSH private key not found' unless key
      key.dump
    end

    def dockercfg
      cfg = File.read(File.join(ENV['HOME'], '.dockercfg')).gsub("\n", '')
      cfg.dump
    end

    def key_path
      %w(id_rsa id_dsa).map { |private_key| ssh_key_path(private_key) }.detect { |path| File.exist? path }
    end

    def ssh_key_path(key)
      File.join(ENV['HOME'], ".ssh/#{key}")
    end
  end
end
