# frozen_string_literal: true

require 'discordrb'
require './tahoiya'

TOKEN = ENV['DISCORD_BOT_TOKEN']
TOKEN.freeze
OK_MARK = "\u{1F197}"
OK_MARK.freeze
CHECK_MARK = "\u{2705}"
CHECK_MARK.freeze
ALPHABET_EMOJI = []
BASECODE = "1F1E6".to_i(16)
26.times do |n|
  ALPHABET_EMOJI.push( (BASECODE+n).chr("UTF-8") )
end
ALPHABET_EMOJI.freeze

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
    embed.color = "#0000ff"
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
