module StreamingHelper
    
    def parse_bool(val, default = false)
        val = ActiveModel::Type::Boolean.new.cast(val)
        val.nil? ? default : val
    end
end
