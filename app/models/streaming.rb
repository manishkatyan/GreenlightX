class Streaming < ApplicationRecord
    validates :url, presence: false
    validates :meeting_id, presence: false
    validates :viewer_url, presence: false
end
