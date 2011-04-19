require 'net/ldap'
require 'json'

class LdapQueryController < ApplicationController
  before_filter :require_login
  layout false

  def find
    respond_to do |format|
      format.json { render :json => search( params[:term] ), :status => 200 }
    end
  end
  
  private

  def search(term)
    term.strip! if term
    return "" if term.blank?
    ldap_attributes = [LDAP_USER_ID, LDAP_FIRST_NAME, LDAP_LAST_NAME, LDAP_PREFERRED_NAME]
    ldap = Net::LDAP.new(
      :host => LDAP_HOST,
      :port => LDAP_PORT,
      :auth => {
        :method   => LDAP_ACCESS_METHOD,
        :username => LDAP_ACCESS_USER,
        :password => LDAP_ACCESS_PASSWORD
      }
    )
  
    results = ldap.search(
      :base          => 'o=University of Notre Dame,st=Indiana,c=US',
      :attributes    => ldap_attributes,
      :filter        => Net::LDAP::Filter.eq( LDAP_USER_ID, "#{term}*" ) | Net::LDAP::Filter.eq( LDAP_AGGREGATE_NAME, "*#{term}*" ),
      :return_result => true
    )
    if results
      data = []
      results.each do |entry|
        result = {}
        result['netid'] = entry[LDAP_USER_ID.to_sym][0]
        formal_nickname = entry[LDAP_PREFERRED_NAME.to_sym][0]
        if formal_nickname && formal_nickname.split(' ').count > 1  # sometimes the formal nickname only contains the first name
          result['name'] = formal_nickname
        else
          result['name'] = "#{entry[LDAP_FIRST_NAME.to_sym][0]} #{entry[LDAP_LAST_NAME.to_sym][0]}"
        end
        data << result
      end
      return JSON.generate(data)
    else
      return ""
    end
  end
end
