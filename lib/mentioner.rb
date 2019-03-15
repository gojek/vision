# frozen_string_literal: true

class Mentioner
  def self.process_mentions(comment)
    usernames = extract_username(comment)
    mentionees = find_mentionees_from_username(usernames)
    Array.wrap(mentionees)
  end

  def self.extract_username(comment)
    content = comment.body
    content.scan(username_extract_regex).map { |username| username.gsub(mention_prefix, '') }
  end

  def self.find_mentionees_from_username(usernames)
    emails = usernames.flat_map { |mention| [mention + '@veritrans.co.id', mention + '@midtrans.com', mention + '@go-jek.com'] }
    User.where(email: emails)
  end

  def self.username_extract_regex
    /(?<!\w)#{mention_prefix}[\w\.]+/
  end

  def self.mention_prefix
    '@'
  end
end
