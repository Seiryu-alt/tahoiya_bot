class Tahoiya
  @@current_tahoiya = nil

  def initialize(asker:, subject:, channel:)
    @asker = asker
    @subject = subject
    @answers = []
    @channel = channel
    @@current_tahoiya = self
  end

  def send_subject
    message = @channel.send_embed do |embed|
      embed.title = 'お題'
      embed.description = @subject
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: @asker.display_name, icon_url: @asker.avatar_url)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "たほいやBOTにDMで回答（出題者は答え）を送信しよう\n全員の回答が終わったら#{OK_MARK}をクリック")
      embed.color = MESSAGE_COLORS[0]
    end
    message.react(OK_MARK)
  end

  def send_descriptions
    @answers.shuffle!
    message = @channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: @asker.display_name, icon_url: @asker.avatar_url)
      embed.title = '本物はどれ？'
      embed.description =  @answers.map.with_index{ |answer, i|
        "#{NUMBER_EMOJI[i]} #{answer[:body]}"
      }.join("\n")
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "全員の投票が終わったら#{CHECK_MARK}をクリック")
      embed.color = MESSAGE_COLORS[1]
    end

    @answers.size.times do |n|
      message.react(NUMBER_EMOJI[n])
    end
    message.react(CHECK_MARK)
  end

  def send_answer(message:)
    reactions = message.reactions
    @answers.each_with_index do |answer, i|
      answer[:votes] = reactions[NUMBER_EMOJI[i]].count-1
    end

    @channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: @asker.display_name, icon_url: @asker.avatar_url)
      embed.title = '答え'
      embed.description = @answers.map.with_index{ |answer, i|
        if answer[:correct]
          "#{NUMBER_EMOJI[i]} 本物 (#{answer[:votes]}票)"
        else
          "#{NUMBER_EMOJI[i]} #{answer[:user].display_name}  (#{answer[:votes]}票)"
        end
      }.join("\n")
      embed.color = MESSAGE_COLORS[2]
    end
  end

  def add_description(user:, body:)
    user = user.on(@channel.server)
    current_answer = @answers.find{|answer| answer[:user] == user}
    if current_answer
      current_answer[:body] = body
    else
      if user == @asker
        @answers.push({user: user, body: body, correct: true})
      else
        @answers.push({user: user, body: body, correct: false})
      end
    end
  end

  def self.current
    @@current_tahoiya
  end
end