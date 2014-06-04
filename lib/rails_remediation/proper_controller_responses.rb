module RailsRemediation
  module ProperControllerResponses
    def self.included(base)
      base.around_filter :handle_record_not_found
    end

    def handle_record_not_found
      yield
      rescue ActiveRecord::RecordNotFound => e
        respond_with({ errors: [ e.message ] },
                     { location: nil, status: :not_found })
    end
  end
end
