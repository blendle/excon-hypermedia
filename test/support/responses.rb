# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/ModuleLength

# :no-doc:
module Test
  # :no-doc:
  module Response
    module_function

    def api_body
      <<-EOF
       {
         "_links": {
           "self": {
             "href": "http://localhost:8000/api.json"
           },
           "product": {
             "href": "http://localhost:8000/product/{uid}",
             "templated": true
           }
         }
       }
     EOF
    end

    def bicycle_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "http://localhost:8000/product/bicycle"
            },
            "handlebar": {
              "href": "http://localhost:8000/product/handlebar"
            },
            "object_id": {
              "href": "http://localhost:8000/product/bicycle/object_id_as_text"
            },
            "pump": {
              "href": "http://localhost:8000/product/pump"
            },
            "wheels": [
              { "href": "http://localhost:8000/product/bicycle/wheels/front" },
              { "href": "http://localhost:8000/product/bicycle/wheels/rear" }
            ]
          },
          "bike-type": "Mountain Bike",
          "BMX": false,
          "derailleurs": {
            "back": 7,
            "front": 3
          },
          "name": "bicycle",
          "reflectors": true,
          "_embedded": {
            "pump": #{pump_body},
            "wheels": [#{front_wheel_body}, #{rear_wheel_body}]
          }
        }
      EOF
    end

    def handlebar_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "http://localhost:8000/product/handlebar"
            }
          },
          "material": "Carbon fiber",
          "reach": "75mm",
          "bend": "compact"
        }
      EOF
    end

    def pump_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "http://localhost:8000/product/pump"
            },
            "parts": {
              "href": "http://localhost:8000/product/pump/parts"
            }
          },
          "weight": "2kg",
          "type": "Floor Pump",
          "valve-type": "Presta",
          "_embedded": {
            "parts": #{parts_body}
          }

        }
      EOF
    end

    def parts_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "http://localhost:8000/product/pump/parts"
            }
          },
          "count": 47
        }
      EOF
    end

    def rear_wheel_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "http://localhost:8000/product/bicycle/wheels/rear"
            }
          },
          "position": "rear",
          "lacing_pattern": "Radial"
        }
      EOF
    end

    def front_wheel_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "http://localhost:8000/product/bicycle/wheels/front"
            }
          },
          "position": "front",
          "lacing_pattern": "Radial/2-Cross"
        }
      EOF
    end
  end
end
