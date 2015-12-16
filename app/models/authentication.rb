class Authentication < ActiveRecord::Base
  belongs_to :person, class_name: 'Fe::Person'

  validates :person_id, presence: true
end
