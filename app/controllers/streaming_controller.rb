class StreamingController < ApplicationController
  # Initialize Global variable pid
  def streaming_status(bbb_id)
    streaming_status = Streaming.find_by(meeting_id: bbb_id )
    if streaming_status
      return streaming_status.attributes
    else
      return false
    end
  end

  def update_streaming_status(streaming_data, bbb_id)
    @streaming = Streaming.find_by(meeting_id: bbb_id )
    if @streaming
      streaming_data.each do |key, value|
        @streaming.update_attribute(:"#{key}", value)
      end
    else
      @streaming = Streaming.new(streaming_data)
      @streaming.save
    end
  end

  def streaming_data
    if !running_streaming.empty?
      current_streaming_data = streaming_status(params[:meeting_id])
      return current_streaming_data
    end
  end
  helper_method :streaming_data

  #method to render select meeting page  i.e "get /streaming"
  def select_meeting
    if current_user.streaming
      @streaming = Streaming.new
      render 'streaming/select_meeting'
    else
      render "errors/greenlight_error", status: 403, formats: :html,
      locals: {
        status_code: 403,
        message: "Streaming is disabled",
        help:"Please contact admin for more details",
      }
    end
  end

  # get /streaming/:meeting_id/show/:meeting_name
  def show
    if current_user.streaming
      @streaming = Streaming.find_by(meeting_id: params[:meeting_id])
      @streaming = Streaming.new if !@streaming
      render 'streaming/create'
    else
      render "errors/greenlight_error", status: 403, formats: :html,
      locals: {
        status_code: 403,
        message: "Streaming is disabled",
        help:"Please contact admin for more details",
      }
    end
  end

  # It  returns running rooms
  def streaming_running_meetings
    user_running_rooms = {}
    current_user.ordered_rooms.each do |room|
      user_running_rooms.store(room.bbb_id, room.name) if room_running?(room.bbb_id) || running_streaming.include?(room.bbb_id)
    end
    return user_running_rooms
  end
  helper_method :streaming_running_meetings

  # pass values to live streaming view page
  def live
    meeting_id = params[:meeting_id]
    @streaming = Streaming.find_by(meeting_id: meeting_id)
    return {:player_url => @streaming.player_url, :chat_url => @streaming.chat_url}
  end
  helper_method :live

  # render chat and player
  def streaming_page
    render 'streaming/streaming_page'
  end
  # streaming starts here i.e "post /streaming"
  def create
    @streaming = Streaming.find_by(meeting_id: params[:meeting_id] )
    @streaming = Streaming.new(streaming_params) if !@streaming
    streaming_status = streaming_status(@streaming.meeting_id)
    streaming_status_update_data = streaming_status ? streaming_status : {} 
    pid = streaming_status ? streaming_status["pid"] : "0" 
    if (params[:commit] == "Start") && (pid == "0") 
      @room = Room.find_by(bbb_id: @streaming.meeting_id)
      bbb_url = Rails.configuration.bigbluebutton_endpoint
      bbb_secret = Rails.configuration.bigbluebutton_secret
      meetingID = @streaming.meeting_id
      attendee_pw = @room.attendee_pw
      show_presentation =  @streaming.show_presentation == "1" ? "true" : "false" 
      hide_user_list_and_chat = Rails.configuration.hide_user_list_and_chat
      rtmp_url =   @streaming.url.ends_with?("/") ? @streaming.url : @streaming.url + "/"
      streaming_key = @streaming.streaming_key
      full_rtmp_url = rtmp_url + streaming_key
      greenlight_url = URI.parse(Rails.configuration.bigbluebutton_endpoint)
      viewer_url = "#{@streaming.meeting_id}/live"
      start_streaming = "node /usr/src/app/bbb-live-streaming/bbb_stream.js #{bbb_url} #{bbb_secret} #{meetingID} #{attendee_pw} #{show_presentation} #{hide_user_list_and_chat} #{full_rtmp_url}
      pid = Process.spawn (start_streaming).to_s
      Process.detach(pid)
      running = true
      streaming_status_update_data = {
        "pid" => pid,
        "meeting_name" => @room.name,
        "url" => rtmp_url,
        "viewer_url" => viewer_url,
        "meeting_id" => meetingID,
        "streaming_key" => streaming_key,
        "running" => running,
        "show_presentation" => show_presentation,
        "streaming_enabled" => current_user.streaming,
        "player_url" => @streaming.player_url,
        "chat_url" => @streaming.chat_url,
      }
      logger.info "streaming_status_update_data: #{streaming_status_update_data}"
      update_streaming_status(streaming_status_update_data, meetingID)
      logger.info "Streaming started at pid: #{pid}"
      flash.now[:success] = ("Streaming started successfully")
      return redirect_to "/streaming/#{@streaming.meeting_id}/show/#{@streaming.meeting_name}"

    elsif (params[:commit] == "Stop") && (streaming_status_update_data["running"])
      begin
        Process.kill('SIGTERM', streaming_status_update_data["pid"].to_i)
        logger.info "Streaming stopped; killed streaming processed, pid: #{pid}"
        pid = "0"
        running = false
        rtmp_url= ''
        streaming_key= ''
        viewer_url= ''
        player_url = ''
        chat_url = ''
        show_presentation= "false" 
        
      rescue => exception
        pid = "0"
        running = false
        rtmp_url= ''
        streaming_key= ''
        viewer_url= ''
        player_url = ''
        chat_url = ''
        show_presentation= "false" 
      end
      streaming_status_update_data["running"] = running
      streaming_status_update_data["pid"] = pid
      streaming_status_update_data["url"] = rtmp_url
      streaming_status_update_data["streaming_key"] = streaming_key
      streaming_status_update_data["viewer_url"] = viewer_url
      streaming_status_update_data["player_url"] = player_url
      streaming_status_update_data["chat_url"] = chat_url
      streaming_status_update_data["show_presentation"] = show_presentation
      update_streaming_status(streaming_status_update_data, @streaming.meeting_id)
      flash.now[:success] = ("Streaming stopped successfully")
      return redirect_to streaming_select_path
    end
  end

  def running_streaming
    Streaming.where(running:true).pluck(:meeting_id)
  end
  helper_method :running_streaming


  # only pass allowed params from "post /streaming"
  def streaming_params
    parameters = Streaming.attribute_names - %w(id created_at updated_at)
    params.require(:streaming).permit(parameters)
  end
end
