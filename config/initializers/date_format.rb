# The API should always return UTC dates
class ActiveSupport::TimeWithZone
    def as_json(options = {})
        utc.strftime('%Y-%m-%d %H:%M:%S')
    end
end
