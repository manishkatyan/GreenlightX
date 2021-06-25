class StreamingController < ApplicationController
  # Initialize Global variable pid
  $pid = 0

  #method to render streaming page i.e "get /streaming"  
  def show
    @streaming = Streaming.new
    render('streaming/create')
  end

  # It returns id the any room that belongs to current user is running?
  def streaming_running_meetings
    all_room_list = {}
    rooms = []
    room_list = {}
    current_user.ordered_rooms.each do |room|
      rooms << room.bbb_id
    end

    all_running_meetings[:meetings].each do |meeting|
      all_room_list.store(meeting[:meetingID], meeting[:meetingName])
    end

    rooms.each do |meetingID|
      if (all_room_list.has_key?(meetingID))
        all_room_list.slice(meetingID).each do |meeting_id, meetingName|
          room_list.store(meeting_id, meetingName)
        end
      end
    end
    return room_list
  end
  helper_method :streaming_running_meetings
  

  # streaming starts here i.e "post /streaming"
  def create
    @streaming = Streaming.new(streaming_params)
    if (params[:commit] == "Start") && ($pid == 0) 
      bbb_url = Rails.configuration.bigbluebutton_endpoint
      bbb_secret = Rails.configuration.bigbluebutton_secret
      meetingID = @streaming.meeting_id
      modorator_pw = Room.find_by(bbb_id: meetingID).moderator_pw
      hide_presentation =  Rails.configuration.hide_presentation
      hide_chat = Rails.configuration.hide_chat
      hide_user_list = Rails.configuration.hide_user_list
      rtmp_url =  @streaming.url
      viewer_url = @streaming.viewer_url
      start_streaming = "cd /usr/src/app/bbb-live-streaming/ && node bbb_stream.js #{bbb_url} #{bbb_secret} #{meetingID} #{modorator_pw} #{hide_presentation} #{hide_chat} #{hide_user_list} #{rtmp_url} #{viewer_url}"
      logger.error "#{start_streaming}"
      $pid = Process.spawn (start_streaming)
      logger.info "Streaming started at pid: #{$pid}"
      flash.now[:success] = ("Streaming started succussfully")

    elsif (params[:commit] == "Stop") && ($pid > 0 )
      `killall --user root  --ignore-case  --signal TERM  node`
      logger.info "Streaming stopped; killed streaming processed, pid: #{$pid}"
      $pid = 0
      flash.now[:success] = ("Streaming stopped succussfully")
    end
  end

  # only pass allowed params from "post /streaming"
  def streaming_params
    parameters = Streaming.attribute_names - %w(id created_at updated_at)
    params.require(:streaming).permit(parameters)
  end
end
