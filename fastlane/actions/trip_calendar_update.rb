module Fastlane
  module Actions
    class TripCalendarUpdateAction < Action
      def self.run(params)
        path = File.join(Dir.pwd, "README.md")
        UI.user_error! "README.md not found under #{path}" unless File.exist? path

        content = add_add_to_calendar_links(path)

        File.write(path, content + "\n")
      end

      def self.add_add_to_calendar_links(path)
        content = File.read(path).split("\n")
        rows = []
        in_table = false
        content.each do |line|
          if in_table
            if line == ""
              in_table = false
            elsif line.start_with? "----"
            else
              line = line[0..line.rindex('|')] + " " +  create_link(line)
            end
          else
            if line.start_with? "Status"
              in_table = true
            end
          end
          rows << line
        end
        rows.join("\n")
      end

      def self.create_link(line)
        cells = line.split("|").map { |s| s.strip! }
        where = cells[1]
        from = to_cal_date(cells[2], "08")
        to = to_cal_date(cells[3], "20") # :)
        purpose = cells[4]
        text = CGI::escape("Fastlane / Felix @ #{where} #{purpose}")
        img_url = 'http://www.google.com/calendar/images/ext/gc_button1.gif'
        calendar_link = "http://www.google.com/calendar/event?action=TEMPLATE&text=#{text}&dates=#{from}/#{to}&details=&location=#{where}&trp=true&sprop=&sprop=name:fastlane"
        "[![Add to calendar](#{img_url})](#{calendar_link})"
      end

      def self.to_cal_date(date, time)
        date.split("-").join("")+"T#{time}0000Z"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Update the trips listing with easy to click add to calendar buttons"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_TRIP_CALENDAR_UPDATE_API_TOKEN", # The name of the environment variable
                                       description: "API Token for TripCalendarUpdateAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No API token for TripCalendarUpdateAction given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
                                          # raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :development,
                                       env_name: "FL_TRIP_CALENDAR_UPDATE_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["lacostej"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end