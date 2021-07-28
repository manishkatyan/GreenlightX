
require 'json'
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

  def update_status_file(streaming_data, bbb_id)
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
    @room = Room.find_by(user_id: session[:user_id])
    current_streaming_data = streaming_status(@room.bbb_id)
    return current_streaming_data
  end
  helper_method :streaming_data

  #method to render streaming page i.e "get /streaming"

  def show
    @streaming = Streaming.new
    if current_user.streaming?
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

  # It returns id the any room that belongs to current user is running?
  def streaming_running_meetings
    user_running_rooms = {}
    current_user.ordered_rooms.each do |room|
      user_running_rooms.store(room.bbb_id, room.name) if room_running?(room.bbb_id)
    end
    return user_running_rooms
  end
  helper_method :streaming_running_meetings
  
  # streaming starts here i.e "post /streaming"
  def create
    @streaming = Streaming.new(streaming_params)
    @room = Room.find_by(bbb_id: @streaming.meeting_id)
    streaming_status = streaming_status(@room.bbb_id)

    status_file_update_data = streaming_status ? streaming_status : {} 

    pid = streaming_status ? streaming_status["pid"] : "0" 
    if (params[:commit] == "Start") && (pid == "0") 
      bbb_url = Rails.configuration.bigbluebutton_endpoint
      bbb_secret = Rails.configuration.bigbluebutton_secret
      meetingID = @streaming.meeting_id
      attendee_pw = @room.attendee_pw
      show_presentation =  @streaming.show_presentation == "1" ? "true" : "false" 
      hide_chat = Rails.configuration.hide_chat
      hide_user_list = Rails.configuration.hide_user_list
      rtmp_url =   @streaming.url.ends_with?("/") ? @streaming.url : @streaming.url + "/"
      streaming_key = @streaming.streaming_key
      full_rtmp_url = rtmp_url + streaming_key
      viewer_url = @streaming.viewer_url
      start_streaming = "node /usr/src/app/bbb-live-streaming/bbb_stream.js #{bbb_url} #{bbb_secret} #{meetingID} #{attendee_pw} #{show_presentation} #{hide_chat} #{hide_user_list} #{full_rtmp_url} #{viewer_url}"
      pid = Process.spawn (start_streaming).to_s
      Process.detach(pid)
      running = true
      status_file_update_data = {
        "pid" => pid,
        "meeting_name" => @room.name,
        "url" => rtmp_url,
        "viewer_url" => viewer_url,
        "meeting_id" => meetingID,
        "streaming_key" => streaming_key,
        "running" => running,
        "show_presentation" => show_presentation,
        "streaming_enabled" => current_user.streaming,
        "vimeo_player_url" => @streaming.vimeo_player_url,
        "vimeo_chat_url" => @streaming.vimeo_chat_url,
      }
      logger.info "status_file_update_data: #{status_file_update_data}"
      update_status_file(status_file_update_data, meetingID)
      logger.info "Streaming started at pid: #{pid}"
      flash.now[:success] = ("Streaming started successfully")

    elsif (params[:commit] == "Stop") && (status_file_update_data["running"])
      begin
        Process.kill('SIGTERM', status_file_update_data["pid"].to_i)
        logger.info "Streaming stopped; killed streaming processed, pid: #{pid}"
        pid = "0"
        running = false
        rtmp_url= ''
        streaming_key= ''
        viewer_url= ''
        vimeo_player_url = ''
        vimeo_chat_url = ''
        show_presentation= "false" 
        
      rescue => exception
        pid = "0"
        running = false
        rtmp_url= ''
        streaming_key= ''
        viewer_url= ''
        vimeo_player_url = ''
        vimeo_chat_url = ''
        show_presentation= "false" 
      end
      status_file_update_data["running"] = running
      status_file_update_data["pid"] = pid
      status_file_update_data["url"] = rtmp_url
      status_file_update_data["streaming_key"] = streaming_key
      status_file_update_data["viewer_url"] = viewer_url
      status_file_update_data["vimeo_player_url"] = vimeo_player_url
      status_file_update_data["vimeo_chat_url"] = vimeo_chat_url
      status_file_update_data["show_presentation"] = show_presentation
      update_status_file(status_file_update_data, @room.bbb_id)
      flash.now[:success] = ("Streaming stopped successfully")
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
