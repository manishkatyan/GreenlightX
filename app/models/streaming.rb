class Streaming < ApplicationRecord

    validates :pid, presence: true
    validates :meeting_name, presence: true
    validates :url, presence: false
    validates :meeting_id, presence: false
    validates :viewer_url, presence: false
    validates :streaming_key, presence: false
    validates :show_presentation, presence: false
    validates :vimeo_player_url, presence: false
    validates :vimeo_chat_url, presence: false
    validates :running, presence: false
    validates :streaming_enabled, presence: false
end
