class EmailFormatValidator < ActiveModel::EachValidator
  EMAIL_FORMAT = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  def validate_each(object, attribute, value)
    unless value =~ EMAIL_FORMAT
      object.errors[attribute] << (options[:message] || "is not valid")
    end
  end
end  