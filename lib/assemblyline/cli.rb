require "assemblyline/cli/version"
require 'thor'

module Assemblyline
  class CLI < Thor
    desc "build URL", "Build an assemblyline project from a git url"
    def build(url)
      exec "docker run --rm -ti -v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock -e SSH_KEY=#{ssh_key} -e DOCKERCFG=#{dockercfg} quay.io/assemblyline/builder:latest bin/build #{url}"
    end

    private

    def ssh_key
      File.read(key_path).dump
    end

    def dockercfg
      File.read(File.join(ENV['HOME'], '.dockercfg')).dump
    end

    def key_path
      %w(id_rsa id_dsa).map { |private_key| ssh_key_path(private_key) }.detect { |path| File.exist? path }
    end

    def ssh_key_path(key)
      File.join(ENV['HOME'], ".ssh/#{key}")
    end
  end
end
