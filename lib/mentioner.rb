class Mentioner
  def self.extract_handles_from_mentioner(mentioner)
      content = self.extract_mentioner_content(mentioner)
      handles = content.scan(self.handle_regexp).map { |handle| handle.gsub("#{mention_prefix}","") }
    end

  def self.extract_mentioner_content(comment)
    comment.body
  end

  def self.find_mentionees_by_handles(*handles)
    handles[0] = handles[0].collect{|mention| mention + "@veritrans.co.id"}
    User.where(email: handles)
  end

  def self.process_mentions(mentioner)
    handles = self.extract_handles_from_mentioner(mentioner)
    if !handles.nil?
      mentionees = self.find_mentionees_by_handles(handles)
    else
      mentionees = nil
    end
    return mentionees
  end

  def self.handle_regexp
    /(?<!\w)#{mention_prefix}[\w\.]+/
  end

  def self.mention_prefix
      "@"
  end


end
