class Settler

  ##
  # The AptGet dependency class supports basic apt-get features:
  #
  #   class MyDeps < Settler
  #     apt_get "ruby", :version => '1.9'
  #   end
  #
  # See the Dependency class for more info.

  class AptGet < Dependency

    def initialize(dependency_lib, name, options={}, &block)
      super(dependency_lib, name, options) do
        pkg_name = build_pkg_name @pkg.dup, options

        install    "sudo apt-get install -y #{pkg_name}"
        uninstall  "sudo apt-get remove -y #{pkg_name}"

        @pkg = "#{@pkg}-#{options[:version]}" if options[:version]
        check_test "sudo apt-cache search ^#{@pkg} | grep -c ^#{@pkg}", '-ge 1'

        instance_eval(&block) if block_given?
      end
    end


    private

    def build_pkg_name pkg_name, options={}
      pkg_name << "=#{options[:version]}" if options[:version]

      pkg_name
    end


    def run_command(command, options={})
      if @dependency_lib.exist?('apt-get')
        @dependency_lib.install 'apt-get', options
      end
      super
    end
  end
end