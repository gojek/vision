class Mentioner
  def self.process_mentions(comment)
    usernames = extract_username(comment)
    mentionees =find_mentionees_from_username(usernames)
    return Array.wrap(mentionees)
  end

  def self.extract_username(comment)
    content = comment.body
    usernames = content.scan(username_extract_regex).map{|username| username.gsub(mention_prefix,'')}
  end

  def self.find_mentionees_from_username(usernames)
    usernames = usernames.map{|mention| mention + '@veritrans.co.id'}
    User.where(email: usernames)
  end

  def self.username_extract_regex
    /(?<!\w)#{mention_prefix}[\w\.]+/
  end

  def self.mention_prefix
    '@'
  end
end
