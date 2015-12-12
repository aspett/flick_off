#!/usr/bin/env ruby

require 'wits'
require 'dotenv'
require 'mailgun'

Dotenv.load

THRESHOLD_FOR_ALERT = 125
THRESHOLD_CHANGE    = 25
SLEEP_TIME          = 30

class PriceAlert
  attr_accessor :last_alert

  def initialize(output = nil)
    @last_alert = nil
    @mailgun = Mailgun::Client.new(ENV['MG_KEY'])
    @output = !(output == "--no-output")
  end

  def get_last
    prices = Wits.five_minute_prices(ENV['GIP_GXP'])
    prices = prices[:prices]

    prices.last
  end

  def alert(latest:, below: false, previous: nil)
    if below
      send_mail(title: '[FLKOF] Price recovered',
                text: "Price has recovered from previously alerted <b>#{previous[:price]}</b>\n down to <b>#{latest[:price]}</b>")

      @last_alert = nil
    else
      if previous
        send_mail(title: "[FLKOF] [#{severity(latest[:price])}] Price has increased",
                  text: "Price has increased from <b>#{previous[:price]}</b>\nto <b>#{latest[:price]}</b>")
      else
        send_mail(title: "[FLKOF] [#{severity(latest[:price])}] Price has increased",
                  text: "Price alert for price at <b>#{latest[:price]}</b>")
      end

      @last_alert = latest
    end
  end

  def severity(price)
    case
    when price > 300
      "EXTREME"
    when price > 200
      "VERY HIGH"
    when price > 150
      "HIGH"
    else
      "CAUTION"
    end
  end

  def send_mail(title:,text:)
    log "\nSending email: #{title}\n\n#{text}\n"
    @mailgun.send_message(ENV['MG_DOMAIN'],
                          { from: ENV['FROM_EMAIL'],
                            to: ENV['TO_EMAIL'],
                            subject: title,
                            html: text })
  end

  def loop
    Kernel.loop do
      main
    end
  end

  def log(text)
    puts text if @output
  end

  def main
    latest = get_last
    if latest[:price] > THRESHOLD_FOR_ALERT
      if last_alert.nil?
        alert(latest: latest)
      elsif (latest[:price] - last_alert[:price]) > THRESHOLD_CHANGE
        alert(previous: last_alert, latest: latest)
      end
    else
      if !last_alert.nil?
        alert(below: true, previous: last_alert, latest: latest)
      end
    end

    log latest
  rescue Wits::Error::ClientError => e
    log "Wits error: #{e.message}"
  ensure
    sleep SLEEP_TIME
  end
end

pa = PriceAlert.new(ARGV[0])
pa.loop
