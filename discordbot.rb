# frozen_string_literal: true

require 'discordrb'
require './tahoiya'

TOKEN = ENV['DISCORD_BOT_TOKEN']
TOKEN.freeze
OK_MARK = "\u{1F197}"
OK_MARK.freeze
CHECK_MARK = "\u{2705}"
CHECK_MARK.freeze
BASECODE = "\u{FE0F}\u{20E3}"
NUMBER_EMOJI = []
9.times do |n|
  NUMBER_EMOJI.push( "#{n+1}#{BASECODE}" )
end
NUMBER_EMOJI.freeze
MESSAGE_COLORS = ['#ff0000', '#ffff00', '#00ff7f', '#0000ff']
MESSAGE_COLORS.freeze

bot = Discordrb::Commands::CommandBot.new token: TOKEN, prefix: '/'

bot.command(:tahoiya) do |event, *args|
  asker = event.user
  subject = args.join(' ')
  tahoiya = Tahoiya.new(asker: asker, subject: subject)
  message = tahoiya.send_subject(channel: event.channel)
  message.react(OK_MARK)
  event.message.delete
end

bot.pm do |event|
  tahoiya = Tahoiya.current
  tahoiya.add_description(user: event.user, body: event.content)
  event.channel.send_embed do |embed|
    embed.title = "回答を受け付けました"
    embed.description = event.content
    embed.color = MESSAGE_COLORS[3]
  end
end

bot.reaction_add(emoji: OK_MARK) do |event|
  message = event.message
  if message.from_bot? && !message.my_reactions.empty?
    Tahoiya.current.send_descriptions(channel: event.channel)
    event.message.delete_all_reactions
  end
end

bot.reaction_add(emoji: CHECK_MARK) do |event|
  message = event.message
  if message.from_bot? && !message.my_reactions.empty?
    Tahoiya.current.send_answer(channel: event.channel)
  end
end

bot.run
