require 'spec_helper'

describe BusAssignmentSearch do
  describe '.find_assignments' do
    it 'returns the assignments belonging to the family identified by the credentials provided' do
      bus_assignment = attributes_for(
        :bus_assignment_response,
        parentfirstname: 'Ned',
        parentlastname: 'Stark',
        studentfirstname: 'Arya',
        studentlastname: 'Stark'
      )

      sample_bus_assignments_response = [bus_assignment.stringify_keys].to_json

      stub_assignments_api do |request|
        request.get('/bpswstr/Connect.svc/bus_assignments') { [200, {}, sample_bus_assignments_response] }
      end

      search = BusAssignmentSearch.find(123)

      search.assignments.should be_instance_of Array

      assignment = search.assignments.first

      assignment['parentfirstname'].should eq 'Ned'
      assignment['parentlastname'].should eq 'Stark'
      assignment['studentfirstname'].should eq 'Arya'
      assignment['studentlastname'].should eq 'Stark'
    end

    it 'handles errors retreiving assignments' do
      stub_assignments_api do |request|
        request.get('/bpswstr/Connect.svc/bus_assignments') { [500, {}, ''] }
      end

      search = BusAssignmentSearch.find(123)

      search.assignments.should be_blank
      search.errors.should have_key :assignments
    end
  end
end
