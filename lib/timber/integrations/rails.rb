require "timber/overrides"

require "timber/config/integrations/rails"

require "timber/integrations/rack/error_event"
require "timber/integrations/rack/http_context"
require "timber/integrations/rack/http_events"
require "timber/integrations/rack/user_context"
require "timber/integrations/rails/session_context"
require "timber/integrations/rails/rack_logger"

require "timber/integrations/action_controller"
require "timber/integrations/action_dispatch"
require "timber/integrations/action_view"
require "timber/integrations/active_record"

require "timber/integrations/rails/logger"

module Timber
  module Integrations
    # Module for holding *all* Rails integrations. This module does *not*
    # extend {Integration} because it's dependent on {Rack::HTTPEvents}. This
    # module simply disables the default HTTP request logging.
    module Rails
      def self.enabled?
        Timber::Integrations::Rack::HTTPEvents.enabled?
      end

      def self.integrate!
        return false if !enabled?

        ActionController.integrate!
        ActionDispatch.integrate!
        ActionView.integrate!
        ActiveRecord.integrate!
        RackLogger.integrate!
      end

      def self.enabled=(value)
        Timber::Integrations::Rack::ErrorEvent.enabled = value
        Timber::Integrations::Rack::HTTPContext.enabled = value
        Timber::Integrations::Rack::HTTPEvents.enabled = value
        Timber::Integrations::Rack::UserContext.enabled = value
        SessionContext.enabled = value

        ActionController.enabled = value
        ActionView.enabled = value
        ActiveRecord.enabled = value
      end

      # All enabled middlewares. The order is relevant. Middlewares that set
      # context are added first so that context is included in subsequent log lines.
      def self.middlewares
        @middlewares ||= [Timber::Integrations::Rack::HTTPContext, SessionContext, Timber::Integrations::Rack::UserContext,
          Timber::Integrations::Rack::HTTPEvents, Timber::Integrations::Rack::ErrorEvent].select(&:enabled?)
      end
    end
  end
end
