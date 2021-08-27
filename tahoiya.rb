class Tahoiya
  @@current_tahoiya = nil

  def initialize(asker:, subject:)
    @asker = asker
    @subject = subject
    @answers = []
    @@current_tahoiya = self
  end

  def send_subject(channel:)
    channel.send_embed do |embed|
      embed.title = 'お題'
      embed.description = @subject
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: @asker.name, icon_url: @asker.avatar_url)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "全員の提出が終わったら#{OK_MARK}をクリック")
      embed.color = MESSAGE_COLORS[0]
    end
  end

  def send_descriptions(channel:)
    @answers.shuffle!
    message = channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: @asker.name, icon_url: @asker.avatar_url)
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

  def send_answer(channel:)
    channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: @asker.name, icon_url: @asker.avatar_url)
      embed.title = '答え'
      embed.description = @answers.map.with_index{ |answer, i|
        if answer[:user] == @asker
          "#{NUMBER_EMOJI[i]} 本物"
        else
          "#{NUMBER_EMOJI[i]} #{answer[:user].name}"
        end
      }.join("\n")

      embed.color = MESSAGE_COLORS[2]
    end
  end

  def add_description(user:, body:)
    current_answer = @answers.find{|answer| answer[:user] == user}
    if current_answer
      current_answer[:body] = body
    else
      @answers.push({user: user, body: body})
    end
  end

  def self.current
    @@current_tahoiya
  end
end