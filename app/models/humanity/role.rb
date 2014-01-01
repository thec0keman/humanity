module Humanity
  class Role < ActiveRecord::Base
    has_many :assignments, dependent: :destroy

    #attr_accessible # none

    validates_presence_of :name

    def humans
      self.assignments.map() { |assign| assign.human }
    end

    def to_s
      name
    end

    def to_sym
      to_s.to_sym
    end
  end
end
