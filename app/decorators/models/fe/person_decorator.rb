Fe::Person.class_eval do

  # EMAIL CODE
  # TODO: should this be moved to FE?  Every new Cru rails app will use this

  attr_accessor :set_email, :set_email2
  after_save :save_set_emails
  scope :joins_emails, -> { joins(%(LEFT OUTER JOIN "email_addresses" ON "email_addresses"."person_id" = "people"."id")) }

  # Sets the primary email address in email_addresses table
  def primary_email_address=(email)
    if new_record?
      self.set_email = email
      return
    end

    old_primaries = email_addresses.select { |email| email.primary == true }
    old_primaries.each do |old_primary|
      old_primary.primary = false
      old_primary.save!
    end

    old_email_record = email_addresses.find { |email_record| email_record.email == email }
    if old_email_record
      old_email_record.primary = true
      old_email_record.save!
    else
      email_addresses.create!(email: email, primary: true)
    end
  end
  alias_method :email=, :primary_email_address=


  def email2=(val)
    if new_record?
      self.set_email = val
      return
    end
    email = email_addresses.where(email: val).first_or_create
    email.update_attribute(:primary, false) if email.primary
    email
  end

  def email2
    email_addresses.find_by(primary: false).try(:email)
  end

  def email
    email_address
  end

  def email_address
    (email_addresses.where(primary: true).order('created_at desc').first ||
     email_addresses.order('created_at desc').first).try(:email)
  end

  # END EMAIL CODE

  def self.create_from_omniauth(omniauth)
    Fe::Person.create!(first_name: first_name(omniauth), last_name: last_name(omniauth), email: email(omniauth))
  end

  def self.first_name(omniauth)
    return nil unless omniauth['extra']
    case omniauth['provider'].to_sym
    when :cas
      omniauth['extra']['firstName']
    when :facebook
      omniauth['extra']['raw_info']['first_name']
    end
  end

  def self.last_name(omniauth)
    return nil unless omniauth['extra']
    case omniauth['provider'].to_sym
    when :cas
      omniauth['extra']['lastName']
    when :facebook
      omniauth['extra']['raw_info']['last_name']
    end
  end

  def self.email(omniauth)
    return nil unless omniauth['extra']
    case omniauth['provider'].to_sym
    when :cas
      return omniauth['info']['email'].downcase if omniauth['info'] && omniauth['info']['email']
      return omniauth['extra']['username'].downcase if omniauth['extra'] && omniauth['extra']['username']
    when :facebook
      omniauth['info']['email'].try(:downcase)
    end
  end

  protected

  def save_set_emails
    self.email = set_email if set_email.present?
    self.email2 = set_email if set_email2.present?
  end
end
