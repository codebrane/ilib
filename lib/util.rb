require 'net/smtp'

class Util
  def Util.unique_id
    (Time.now.to_i + rand(100_000_000)).to_s(16)
  end
  
  # http://snippets.dzone.com/posts/show/491
  def Util.generate_password
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(10) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end
  
  def Util.send_email(to, subject, message)
    msgstr = <<-END_OF_MESSAGE
        From: iLib <ilib@codebrane.com>
        To: #{to} <#{to}>
        Subject: iLib Reading List Password

        #{message}
        END_OF_MESSAGE

    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message msgstr,
                        'ilib@codebrane.com',
                        "#{to}"
    end
  end
end