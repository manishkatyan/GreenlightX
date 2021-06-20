class SubscriptionsController < ApplicationController
  def stripe
    Stripe.api_key = ENV['STRIPE_API_KEY']

    portal_session = Stripe::BillingPortal::Session.create(
      customer: current_user.subscription_id,
      return_url: 'http://localhost:3030/'
    )

    redirect_to portal_session.url 
  end
end

