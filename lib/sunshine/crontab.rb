module Sunshine

  ##
  # A simple namespaced grouping of cron jobs that can be written
  # to a deploy server.

  class Crontab

    attr_reader :jobs, :name

    def initialize name
      @name = name
      @jobs = Hash.new{|hash, key| hash[key] = []}
    end


    ##
    # Add a cron command to a given namespace:
    #   crontab.add "logrotote", "00 * * * * /usr/sbin/logrotate"

    def add namespace, cron_cmd
      @jobs[namespace] << cron_cmd unless @jobs[namespace].include?(cron_cmd)
    end

    ##
    # Build the crontab by replacing preexisting cron jobs and adding new ones.

    def build crontab=""
      crontab.strip!

      @jobs.each do |namespace, cron_arr|
        crontab = delete_jobs crontab, namespace

        start_id, end_id = get_job_ids namespace
        cron_str = "\n#{start_id}\n#{cron_arr.join("\n")}\n#{end_id}\n\n"

        crontab << cron_str
      end

      crontab
    end


    ##
    # Remove all cron jobs that reference crontab.name

    def delete! deploy_server
      crontab = read_crontab deploy_server
      crontab = delete_jobs crontab

      write_crontab crontab, deploy_server

      crontab
    end



    ##
    # Write the crontab on the given deploy_server

    def write! deploy_server
      crontab = build read_crontab(deploy_server)

      write_crontab crontab, deploy_server

      crontab
    end


    private

    def read_crontab deploy_server
      deploy_server.call("crontab -l") rescue ""
    end


    def write_crontab content, deploy_server
      deploy_server.call("echo '#{content.gsub(/'/){|s| "'\\''"}}' | crontab")
    end


    def delete_jobs crontab, namespace=nil
      start_id, end_id = get_job_ids namespace

      crontab.gsub!(/^#{start_id}$(.*?)^#{end_id}$\n*/m, "")

      crontab
    end


    def get_job_ids namespace=nil
      namespace ||= "[^\n]*"

      start_id = "# sunshine #{@name}:#{namespace}:begin"
      end_id = "# sunshine #{@name}:#{namespace}:end"

      return start_id, end_id
    end
  end
end
