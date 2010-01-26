require 'test/test_helper'

class TestSunshine < Test::Unit::TestCase

  def setup
  end


  def test_default_config
    config = Sunshine::DEFAULT_CONFIG
    Sunshine.setup config

    assert Sunshine::Console === Sunshine.console

    assert_equal config['deploy_env'], Sunshine.deploy_env

    assert_equal !config['auto'], Sunshine.interactive?

    assert Sunshine::Output === Sunshine.output
    assert_equal Logger::INFO, Sunshine.output.logger.level

    assert_equal config['max_deploy_versions'], Sunshine.max_deploy_versions

    assert_equal config['trace'], Sunshine.trace?
  end


  def test_find_command
    assert !Sunshine.find_command('st')
    assert_equal 'start', Sunshine.find_command('sta')
    assert_equal 'stop', Sunshine.find_command('sto')
    assert_equal 'add', Sunshine.find_command('a')

    Sunshine::COMMANDS.each do |cmd|
      assert_equal cmd, Sunshine.find_command(cmd)
    end
  end


  def test_run_deploy_command
    mock_sunshine_exit
    mock_sunshine_command Sunshine::DeployCommand

    Sunshine.run %w{deploy somefile.rb -l debug -e prod}

    assert_command Sunshine::DeployCommand, [['somefile.rb'], Sunshine.setup]
  end


  def test_run_control_commands
    mock_sunshine_exit

    %w{add list restart rm start stop}.each do |name|
      cmd = Sunshine.const_get("#{name.capitalize}Command")

      mock_sunshine_command cmd

      Sunshine.run %w{thing1 thing2 -r remoteserver.com}.unshift(name)

      ds = Sunshine::DeployServer.new "remoteserver.com"
      dsd = Sunshine::DeployServerDispatcher.new ds

      args = [%w{thing1 thing2}, Sunshine.setup]
      assert_command cmd, args

      assert_equal dsd, Sunshine.setup['servers']


      Sunshine.run %w{thing1 thing2 -v}.unshift(name)
      dsd = [Sunshine.console]

      assert_command cmd, args

      assert_equal dsd, Sunshine.setup['servers']
      assert Sunshine.setup['verbose']
    end
  end


  def test_run_local_cmd
    mock_sunshine_exit
    mock_sunshine_command Sunshine::RmCommand

    Sunshine.run %w{rm app1 app2}

    dsd = [Sunshine.console]

    args = [['app1', 'app2'], Sunshine.setup]
    assert_command Sunshine::RmCommand, args

    assert_equal dsd, Sunshine.setup['servers']
  end


  def test_exit
    assert_sunshine_exit_status [true], 0
    assert_sunshine_exit_status [false], 1
    assert_sunshine_exit_status [0, "success!"], 0, "success!"
    assert_sunshine_exit_status [2, "failed!"], 2, "failed!"
  end


  def assert_sunshine_exit_status args, expected_status, msg=""
    args.map!{|a| a.inspect.gsub("\"", "\\\"")}
    args = args.join(",")
    cmd = "ruby -Ilib -e \"require 'sunshine'; Sunshine.exit(#{args})\""

    pid, inn, out, err = Open4.popen4(*cmd)

    status = Process.waitpid2(pid).last

    out_data = out.read
    err_data = err.read

    out.close
    err.close
    inn.close

    assert_equal expected_status, status.exitstatus
    if expected_status == 0
      assert_equal msg, out_data.strip
    else
      assert_equal msg, err_data.strip
    end
  end


  def assert_command cmd, args
    assert cmd.call_log.include?([:exec, args])
  end


  def mock_sunshine_command cmd
    cmd.class_eval do
      def self.call_log
        @call_log ||= []
      end

      def self.exec *args
        call_log << [:exec, args]
        true
      end
    end
  end

  def mock_sunshine_exit
    Sunshine.class_eval do
      def self.exit *args
      end
    end
  end

end