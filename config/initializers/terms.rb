# frozen_string_literal: true

# Load terms and conditions.

terms = "#{Rails.root}/config/terms.md"
privacy = "#{Rails.root}/config/privacy.md"

Rails.configuration.terms = if File.exist?(terms)
  File.read(terms)
else
  false
end

Rails.configuration.privacy = if File.exist?(privacy)
  File.read(privacy)
else
  false
end
