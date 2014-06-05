module RailsRemediation
  # A mixin for controllers so that they automatically send the correct
  # HTTP response codes (40X) instead of 500 errors when the fault really lies
  # with the parameters supplied by the client.
  module ProperControllerResponses
    class ParameterError < ::ActionController::ActionControllerError
    end
    class ParameterMissing < ParameterError
    end
    class InvalidParameter < ParameterError
    end

    def self.included(base)
      base.around_filter :handle_bad_client_input
    end

    def required_param(param_name)
      raise(ParameterMissing, "#{param_name} is a required parameter") unless params[param_name]
      params[param_name]
    end

    def handle_bad_client_input
      yield
      rescue ActiveRecord::RecordNotFound => e1
        respond_with({ errors: [ e1.message ] },
                     { location: nil, status: :not_found })
      rescue ParameterError => e2
        respond_with({ errors: [ e2.message ] },
                     { location: nil, status: :unprocessable_entity })

    end
  end
end
