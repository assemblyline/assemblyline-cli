require "assemblyline/cli/version"
require 'thor'

module Assemblyline
  class CLI < Thor
    desc "build URL (REF)", "Build an assemblyline project from a git url and optionaly merge REF into master"
    def build(url, ref=nil)
      exec "docker run --rm -v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock -e SSH_KEY=#{ssh_key} -e DOCKERCFG=#{dockercfg} quay.io/assemblyline/builder:latest bin/build #{url} #{ref}"
    end

    private

    def ssh_key
      key = File.read(key_path)
      fail "SSH private key not found" unless key
      key.dump
    end

    def dockercfg
      cfg = File.read(File.join(ENV['HOME'], '.dockercfg')).gsub("\n",'')
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
