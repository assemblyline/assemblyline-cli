# Assemblyline::Cli

A super-lightweight wrapper to start init.d services inside dockerised test containers

## Installation

Add this line to your application's Gemfile:

    gem 'assemblyline-cli'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install assemblyline-cli

## Usage

Include the services to start in the ASSEMBLYLINE_SERVICES environment var.
Pass the test command to run in as args.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/assemblyline-cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
