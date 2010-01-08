module Sunshine

  module DeployCommand

    def self.exec argv
      deploy_file = argv.first
      deploy_file = File.join(deploy_file, "Sunshine") if
        deploy_file && File.directory?(deploy_file)

      deploy_file ||= "Sunshine"
      puts "Running #{deploy_file}"

      require deploy_file
    end


    def self.parse_args argv
      options = {}

      opts = OptionParser.new do |opt|
        opt.program_name = File.basename $0
        opt.version = Sunshine::VERSION
        opt.release = nil
        opt.banner = <<-EOF

Usage: #{opt.program_name} deploy [deploy_file] [options]

Arguments:
    deploy_file     Load a deploy script or app path. Defaults to ./Sunshine
        EOF

        opt.separator nil
        opt.separator "Options:"

        opt.on('-l', '--level LEVEL',
               'Set trace level. Defaults to info.') do |value|
          options['level'] = value
        end

        opt.on('-e', '--env DEPLOY_ENV',
               'Sets the deploy environment. Defaults to development.') do |value|
          options['deploy_env'] = value
        end

        opt.on('-a', '--auto',
               'Non-interactive - automate or fail') do
          options['auto'] = true
        end
      end

      opts.parse! argv

      options
    end
  end
end
