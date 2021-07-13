module StackMaster
  module AwsDriver
    class CloudFormation
      extend Forwardable

      def region
        @region ||= ENV['AWS_REGION'] || Aws.config[:region] || Aws.shared_config.region
      end

      def endpoint_url
        @endpoint_url ||= Aws.config[:endpoint]
      end

      def set_region(value)
        if region != value
          @region = value
          @cf = nil
        end
      end

      def set_endpoint_url(value)
        if endpoint_url != value
          @endpoint_url = value
          @cf = nil
        end
      end

      def changesets_available?
        # XXX: localstack doesn't support changesets and is currently the only
        # use-case for setting the endpoint url.  This may need to grow up eventually.
        @endpoint_url.nil?
      end

      def_delegators :cf, :create_change_set,
                          :describe_change_set,
                          :execute_change_set,
                          :delete_change_set,
                          :delete_stack,
                          :cancel_update_stack,
                          :describe_stack_resources,
                          :get_template,
                          :get_stack_policy,
                          :set_stack_policy,
                          :describe_stack_events,
                          :update_stack,
                          :create_stack,
                          :validate_template,
                          :describe_stacks,
                          :detect_stack_drift,
                          :describe_stack_drift_detection_status,
                          :describe_stack_resource_drifts

      private

      def cf
        return @cf if @cf

        cf_opts = {region: region, retry_limit: 10}
        cf_opts[:endpoint] = endpoint_url if endpoint_url
        @cf = Aws::CloudFormation::Client.new(cf_opts)
      end

    end
  end
end
