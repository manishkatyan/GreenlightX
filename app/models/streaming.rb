class Streaming < ApplicationRecord
    validates :url, presence: false
    validates :meeting_id, presence: false
    validates :viewer_url, presence: false
    validates :streaming_key, presence: false
    validates :hide_presentation, presence: false
end
