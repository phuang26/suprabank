Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.custom_options = lambda do |event|
    unwanted_keys = %w[format action controller]
    params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }

    # capture some specific timing values you are interested in
    {:params => params }
  end


end
