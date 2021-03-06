require_relative 'client_proxy'
require_relative 'lead'

# Implements Lead operations for Marketo.
class MarketoAPI::Leads < MarketoAPI::ClientProxy
  # Creates a new lead with a proxy to this Leads instance.
  #
  # :call-seq:
  #   new -> Lead
  #   new { |lead| ... } -> Lead
  #   new(options) -> Lead
  #   new(options) { |lead| ... } -> Lead
  def new(options = {}, &block)
    MarketoAPI::Lead.new(options.merge(proxy: self), &block)
  end

  # Implements
  # {+getLead+}[http://developers.marketo.com/documentation/soap/getlead/],
  # returning a MarketoAPI::Lead object.
  #
  # :call-seq:
  #   get(lead_key) -> Lead
  #   get(key_type, key_value) -> Lead
  def get(type_or_key, value = nil)
    key = case type_or_key
          when Hash
            if lk = type_or_key[:leadKey]
              if MarketoAPI::Lead.send(:key_type, lk[:keyType])
                type_or_key
              end
            end
          when MarketoAPI::Lead
            transform_param(__method__, type_or_key)
          else
            MarketoAPI::Lead.key(type_or_key, value)
          end

    unless key
      raise ArgumentError, "#{type_or_key} is not a valid lead key"
    end
    extract_from_response(call(:get_lead, key), :lead_record_list) { |record|
      MarketoAPI::Lead.from_soap_hash(record[:lead_record]) do |lead|
        lead.proxy = self
      end
    }
  end

  # Implements
  # {+syncLead+}[http://developers.marketo.com/documentation/soap/synclead/],
  # returning a MarketoAPI::Lead object.
  #
  # :call-seq:
  #   sync(Lead) -> Lead
  def sync(lead_record)
    extract_from_response(
      call(:sync_lead, transform_param(__method__, lead_record)),
    ) { |record|
      MarketoAPI::Lead.from_soap_hash(record[:lead_record]) do |lead|
        lead.proxy = self
      end
    }
  end

  def get_multiple(selector) #:nodoc:
    raise NotImplementedError
  end

  # Implements
  # {+syncMultipleLeads+}[http://developers.marketo.com/documentation/soap/syncmultipleleads/],
  # returning an array of MarketoAPI::Lead objects.
  #
  # May optionally disable de-duplication by passing <tt>dedup_enabled:
  # false</tt>.
  #
  # :call-seq:
  #   sync_multiple(leads) -> array of Lead
  #   sync_multiple(leads, dedup_enabled: false) -> array of Lead
  def sync_multiple(leads, options = { dedup_enabled: true })
    response = call(
      :sync_multiple_leads,
      dedupEnabled:   options[:dedup_enabled],
      leadRecordList: transform_param_list(:sync, leads)
    )
    extract_from_response(response, :lead_record_list) do |list|
      list.each do |record|
        MarketoAPI::Lead.from_soap_hash(record[:lead_record]) do |lead|
          lead.proxy = self
        end
      end
    end
  end

  def merge(winning_key, losing_keys) #:nodoc:
    raise NotImplementedError
  end

  def activity(lead_key, options = {}) #:nodoc:
    raise NotImplementedError
  end

  def changes(start_position, options = {}) #:nodoc:
    raise NotImplementedError
  end

  ##
  # :method: get_by_id
  # :call-seq: get_by_id(marketo_id)
  #
  # Gets the Lead by the provided Marketo ID.

  ##
  # :method: get_by_cookie
  # :call-seq:
  #   get_by_cookie(cookie) -> Lead
  #
  # Gets the Lead by the provided Marketo Munchkin cookie.

  ##
  # :method: get_by_email
  # :call-seq:
  #   get_by_email(email) -> Lead
  #
  # Gets the Lead by the provided lead email.

  ##
  # :method: get_by_lead_owner_email
  # :call-seq:
  #   get_by_lead_owner_email(lead_owner_email) -> Lead
  #
  # Gets the Lead by the provided Lead Owner email.

  ##
  # :method: get_by_salesforce_account_id
  # :call-seq:
  #   get_by_salesforce_account_id(salesforce_account_id) -> Lead
  #
  # Gets the Lead by the provided SFDC Account ID.

  ##
  # :method: get_by_salesforce_contact_id
  # :call-seq:
  #   get_by_salesforce_contact_id(salesforce_contact_id) -> Lead
  #
  # Gets the Lead by the provided SFDC Contact ID.

  ##
  # :method: get_by_salesforce_lead_id
  # :call-seq:
  #   get_by_salesforce_lead_id(salesforce_lead_id) -> Lead
  #
  # Gets the Lead by the provided SFDC Lead ID.

  ##
  # :method: get_by_salesforce_lead_owner_id
  # :call-seq:
  #   get_by_salesforce_lead_owner_id(salesforce_lead_owner_id) -> Lead
  #
  # Gets the Lead by the provided SFDC Lead Owner ID.

  ##
  # :method: get_by_salesforce_opportunity_id
  # :call-seq: get_by_salesforce_opportunity_id(salesforce_opportunity_id)
  #
  # Gets the Lead by the provided SFDC Opportunity ID.

  MarketoAPI::Lead::NAMED_KEYS.each_pair { |name, key|
    define_method(:"get_by_#{name}") do |value|
      get(key, value)
    end
  }
end
