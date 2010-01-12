module Sunshine

  #TODO : Talk to app support about changing the way healthcheck is done,
  #       instead of checking the existance of some random files... weird!
  class Healthcheck

    def initialize(app)
      @app = app
      @hc_file = "#{@app.shared_path}/health.txt"
      @hc_disabled_file = "#{@app.shared_path}/health.disabled"
    end


    ##
    # Disables healthcheck - status: :disabled

    def disable!
      Sunshine.logger.info :healthcheck, "Disabling healthcheck" do
        @app.deploy_servers.run "touch #{@hc_disabled_file} && rm -f#{@hc_file}"
      end
    end


    ##
    # Enables healthcheck which should set status to :ok

    def enable!
      Sunshine.logger.info :healthcheck, "Enabling healthcheck" do
        @app.deploy_servers.run "rm -f #{@hc_disabled_file}"
        @app.deploy_servers.run "touch #{@hc_file}"
      end
    end


    ##
    # Remove the healthcheck file - status: :down

    def remove!
      Sunshine.logger.info :healthcheck, "Removing healthcheck" do
        @app.deploy_servers.run \
          "rm -f #{@hc_disabled_file} #{@hc_file}"
      end
    end


    ##
    # Get the health status of each deploy server.
    # Returns a hash: {'deployserver' => :status}
    # Status has three states:
    #   :ok:        everything is peachy
    #   :disabled:  healthcheck was explicitely turned off
    #   :down:      um, something may be wrong

    def status
      stat = {}
      @app.deploy_servers.each do |ds|
        stat[ds.host] = {}
        stat[ds.host] = :disabled and next if ds.file? @hc_disabled_file
        stat[ds.host] = :ok and next if ds.file? @hc_file
        stat[ds.host] = :down
      end
      stat
    end
  end
end
