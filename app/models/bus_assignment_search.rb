class BusAssignmentSearch
  extend ActiveModel::Naming

  class_attribute :connection, instance_writer: false
  self.connection = Faraday.new(ENV['BPS_API'])

  attr_reader :assignments, :errors

  def self.find(aspen_contact_id)
    new(aspen_contact_id).find
  end

  def initialize(aspen_contact_id)
    @aspen_contact_id = aspen_contact_id
    @errors           = ActiveModel::Errors.new(self)
  end

  def find
    response = connection.get(
      '/bpswstr/Connect.svc/bus_assignments',
      aspen_contact_id: @aspen_contact_id,
      TripFlag: trip_flag,
      ForThisDate: current_date,
      UserName: username,
      Password: password
    )

    if response.success?
      @assignments = JSON.parse(response.body)
    else
      @errors.add(:assignments, "could not be retreived (#{response.status})")
    end

    return self
  end

  private

  def trip_flag
    # FIXME: This needs to be conditionalized based on time of day?
    'arival'
  end

  def current_date
    time_of_request.strftime('%D')
  end

  def time_of_request
    @time_of_request ||= Time.zone.now
  end

  def username
    ENV['BPS_USERNAME']
  end

  def password
    ENV['BPS_PASSWORD']
  end
end
