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
    usernames_vt = usernames.map { |mention| mention + '@veritrans.co.id' }
    usernames_mt = usernames.map { |mention| mention + '@midtrans.com' }
    usernames_gojek = usernames.map { |mention| mention + '@go-jek.com' }
    User.where(email: [usernames_vt, usernames_mt, usernames_gojek])
    # TODO: remove usernames_vt and usernames_mt when migrating to gojek
  end

  def self.username_extract_regex
    /(?<!\w)#{mention_prefix}[\w\.]+/
  end

  def self.mention_prefix
    '@'
  end
end
