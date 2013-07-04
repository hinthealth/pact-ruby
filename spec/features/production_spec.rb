require 'pact/producer/rspec'
require 'features/fixtures/mas'

class ServiceUnderTest

  def call(env)
    case env['PATH_INFO']
    when '/donuts'
      [201, {'Content-Type' => 'application/json'}, { message: "Donut created." }.to_json]
    when '/charlie'
      [200, {'Content-Type' => 'application/json'}, { message: "Your charlie has been deleted" }.to_json]
    end
  end

end

class ServiceUnderTestWithFixture

  def find_zebra_names
    #simulate loading data from a database
    data = JSON.load(File.read('tmp/a_mock_database.json'))
    data.collect{ | zebra | zebra['name'] }
  end

  def call(env)
    case env['PATH_INFO']
    when "/zebra_names"
        [200, {'Content-Type' => 'application/json'}, { names: find_zebra_names }.to_json]
    end
  end

end

module Pact::Producer

  describe "A service production side of a pact" do

    def app
      ServiceUnderTest.new
    end

    pact = JSON.load <<-EOS
    [
        {
            "description": "donut creation request",
            "request": {
                "method": {
                    "json_class": "Symbol",
                    "s": "post"
                },
                "path": "/donuts"
            },
            "response": {
                "body": {"message": "Donut created."},
                "status": 201
            }
        },
        {
            "description": "charlie deletion request",
            "request": {
                "method": {
                    "json_class": "Symbol",
                    "s": "delete"
                },
                "path": "/charlie"
            },
            "response": {
                "body": {
                  "message": {
                    "json_class": "Regexp",
                    "o": 0,
                    "s": "deleted"
                  }
                },
                "status": 200
            }
        }
    ]
    EOS

    honour_pact pact

  end

  describe "with a fixture" do

    def app
        ServiceUnderTestWithFixture.new
    end

    pact = JSON.load <<-EOS
    [
        {
            "description": "donut creation request",
            "request": {
                "method": {
                    "json_class": "Symbol",
                    "s": "post"
                },
                "path": "/zebra_names"
            },
            "response": {
                "body": {"names": ["Jason", "Sarah"]},
                "status": 200
            },
            "producer_state_name" : "all_the_zebras"
        }
    ]
    EOS

    honour_pact pact
  end
end
