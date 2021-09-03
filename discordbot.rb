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
MESSAGE_COLORS = ['#ff0000', '#ffff00', '#00ff7f', '#0000ff', '#ff1493']
MESSAGE_COLORS.freeze

bot = Discordrb::Commands::CommandBot.new token: TOKEN, prefix: '/'

bot.command(:tahoiya, aliases: [:たほいや]) do |event, *args|
  asker = event.author
  subject = args.join(' ')
  tahoiya = Tahoiya.new(asker: asker, subject: subject, channel: event.channel)
  tahoiya.send_subject
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
    if Tahoiya.current.send_descriptions
      event.message.delete_all_reactions
    end
  end
end

bot.reaction_add(emoji: CHECK_MARK) do |event|
  message = event.message
  if message.from_bot? && !message.my_reactions.empty?
    Tahoiya.current.send_answer(message: message)
    event.message.delete_all_reactions
  end
end

bot.run
