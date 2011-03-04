class Event < ActiveRecord::Base

  TYPES = [:lecture, :workshop, :podium, :lightning_talk, :meeting, :other]
  STATES = {
    :undecided => [:new, :review, :withdrawn],
    :accepted => [:unconfirmed, :confirmed, :canceled],
    :rejected => [:done]
  }

  has_many :event_attachments
  has_many :event_people
  has_many :people, :through => :event_people
  has_many :links, :as => :linkable

  belongs_to :conference
  belongs_to :track
  belongs_to :room

  has_attached_file :logo, 
    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
    :default_url => "/images/event_:style.png"

  accepts_nested_attributes_for :event_attachments, :reject_if => :all_blank
  accepts_nested_attributes_for :event_people, :reject_if => :all_blank
  accepts_nested_attributes_for :links, :allow_destroy => true, :reject_if => :all_blank

  validates_attachment_content_type :logo, :content_type => [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :title, :time_slots

  acts_as_indexed :fields => [:title, :subtitle, :event_type, :abstract, :description]

end