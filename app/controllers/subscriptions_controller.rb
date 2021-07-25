class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook


  def webhook
    payload = request.body.read
    event = nil
    begin
      event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
    rescue JSON::ParserError => e
      # Invalid payload
      return false
    end
  
    # Handle the event
    case event.type

    when 'customer.subscription.trial_will_end'
      logger.info "Subscription id : #{event.data.object.customer}"
      subscription_id = event.data.object.id
      begin
        logger.info "trial ends"
      rescue => exception
        logger.info "Couldn't find the user with subscription_id: #{subscription_id}"
      end

    when 'invoice.upcoming'
      begin
        user = User.find_by(customer_id: event.data.object.customer)
        logger.info "#{event.data.object.customer} upcaming event"
      rescue => exception
        logger.info exception
      end
    end
    
  end

  def show
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    portal_session = Stripe::BillingPortal::Session.create(
      customer: current_user.customer_id,
      return_url: ENV['STRIPE_SUBSCRIPTION_RETURN_URL']
    )

    redirect_to portal_session.url 
  end

  def create 
    params[:plan_id]
   end
  helper_method :create

  def success
  # Response from Stripe after a successful payment. Retrieve user's details from session_id and send to signup page
  end


  def cancel
    flash.now[:error] = "Something went wrong... couldn't subscribe"
    redirect_to :root
  end

end

