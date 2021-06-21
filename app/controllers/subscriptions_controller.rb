class SubscriptionsController < ApplicationController
  def show
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    portal_session = Stripe::BillingPortal::Session.create(
      customer: current_user.subscription_id,
      return_url: ENV['STRIPE_SUBSCRIPTION_RETURN_URL']
    )

    redirect_to portal_session.url 
  end

  def create 
  # Stripe Checkout Session create and page recirect  in create.html.erb
  end

  def success
  # Response from Stripe after a successful payment. Retrieve user's details from session_id and send to signup page
  end

  def cancel
    flash.now[:error] = "Something went wrong... couldn't subscribe"
    redirect_to :root
  end

end

