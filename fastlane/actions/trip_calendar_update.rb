module Fastlane
  module Actions
    class TripCalendarUpdateAction < Action
      def self.run(_params)
        path = File.join(Dir.pwd, 'README.md')
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
            if line == ''
              in_table = false
            elsif line.start_with? '----'
            else
              line = line[0..line.rindex('|')] + ' ' + create_link(line)
            end
          else
            in_table = true if line.start_with? 'Status'
          end
          rows << line
        end
        rows.join("\n")
      end

      def self.create_link(line)
        cells = line.split('|').map(&:strip!)
        where = cells[1]
        from = to_cal_date(cells[2], '08')
        to = to_cal_date(cells[3], '20') # :)
        purpose = cells[4]
        text = CGI.escape("Fastlane / Felix @ #{where} #{purpose}")
        calendar_link = "https://www.google.com/calendar/event?action=TEMPLATE&text=#{text}&dates=#{from}/#{to}&details=&location=#{where}&trp=true&sprop=&sprop=name:fastlane"
        "[Add to calendar](#{calendar_link})"
      end

      def self.to_cal_date(date, time)
        date.split('-').join('') + "T#{time}0000Z"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Update the trips listing with easy to click add to calendar buttons'
      end

      def self.available_options
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ['lacostej']
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
