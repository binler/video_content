require 'yaml'
class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  default_url_options[:host] = "#{APPLICATION_HOST}#{BASE_URI}"

  mail_config = YAML.load(File.open(File.join(Rails.root, "config/mailer.yml")))
  mail_config.each_pair do |name,mail_params|
    method_name = "#{name}_notice"
    self.send(:define_method,:"#{method_name}") {|user,*opts| notice(user,mail_params['from_address'],mail_params['subject_text'],mail_params['body_text'],mail_params['template_file'],*opts)}
  end
  
  def notice(to_address, from_address, subject_text, body_text, template_file, opts={})
    recipients to_address

    from_address = opts[:from_address] if opts[:from_address]
    from from_address
    
    #substitute in opts values
    opts.each_pair do |key,value|
      subject_text.sub!("\#\{:#{key}\}",value)
      subject_text.sub!("\#\{#{key}\}",value)
    end

    #replace opts references that may have been missed 
    subject_text.sub!(/#\{.*\}/,'')   

    #now do same substitutions for body text
    opts.each_pair do |key,value|
      body_text.sub!("\#\{:#{key}\}",value)
      body_text.sub!("\#\{#{key}\}",value)
    end

    #replace opts references that may have been missed 
    body_text.sub!(/#\{.*\}/,'')
   
    subject subject_text
    sent_on Time.now
    body({:text=> body_text, :host => "#{APPLICATION_HOST}#{BASE_URI}"}.merge(opts))
    content_type "text/html"
    template template_file
  end
end
