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

    when 'payment_intent.succeeded'
      payment_reciept = event.data.object.charges.data[0].receipt_url
      payment_receipt_number = event.data.object.charges.data[0].receipt_number
      logger.info "Support: payment_reciept: #{payment_reciept}\n payment_receipt_number: #{payment_receipt_number}"

    when 'customer.subscription.trial_will_end'
      subscription_id = event.data.object.id
      begin
        logger.info "Support: Customer Trial will end soon Subscription id : #{event.data.object.customer}"
      rescue => exception
        logger.info "Support: Couldn't find the user with subscription_id: #{subscription_id}"
      end

    when 'invoice.upcoming'
      begin
        user = User.find_by(customer_id: event.data.object.customer)
        logger.info "Support: Upcoming invoice for #{user.name},customer id: #{event.data.object.customer}"
      rescue => exception
        logger.info exception
      end
    end
  end

  def show
    Stripe.api_key = Rails.configuration.stripe_secret_key

    portal_session = Stripe::BillingPortal::Session.create(
      customer: current_user.customer_id,
      return_url: Rails.configuration.stripe_subscription_return_url
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

