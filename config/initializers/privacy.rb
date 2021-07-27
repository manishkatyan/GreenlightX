# frozen_string_literal: true

# Load terms and conditions.

privacy = "#{Rails.root}/config/privacy.md"

Rails.configuration.privacy = if File.exist?(privacy)
  File.read(privacy)
else
  false
end

