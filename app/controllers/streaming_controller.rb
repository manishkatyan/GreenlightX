class StreamingController < ApplicationController
  def create
    @streaming = Streaming.new
  end
end
