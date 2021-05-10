require 'securerandom'
require 'tree'
require 'rspec/core'

require_relative '../../reportportal'
require_relative './formatter'

module ReportPortal
  module RSpec
    class ParallelFormatter < Formatter
      ::RSpec::Core::Formatters.register self, :start, :example_group_started, :example_group_finished,
                                         :example_started, :example_passed, :example_failed,
                                         :example_pending, :message, :stop

      def initialize(_output)
        ENV['REPORT_PORTAL_USED'] = 'true'
      end

      def attach_to_launch?
        ReportPortal::Settings.instance.formatter_modes.include?('attach_to_launch')
      end

      def start(_start_notification)
        if attach_to_launch?
          ReportPortal.launch_id =
            if ReportPortal::Settings.instance.launch_id
              ReportPortal::Settings.instance.launch_id
            else
              file_path = ReportPortal::Settings.instance.file_with_launch_id || (Pathname(Dir.tmpdir) + 'rp_launch_id.tmp')
              File.read(file_path)
            end
          @root_node = Tree::TreeNode.new(SecureRandom.hex)
          @current_group_node = @root_node
          puts "Attaching to launch #{ReportPortal.launch_id}"
        else
          super
        end
      end

      def stop(_notification)
        if attach_to_launch?
          puts "DO nothing... call rake reportportal:finish_launch to finish execution"
        else
          super
        end
      end
    end
  end
end
