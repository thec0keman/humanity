module Humanity
  module Base
    def self.included(base)
      base.has_many :assignments, as: :human, dependent: :destroy, class_name: 'Humanity::Assignment'
      base.has_many :roles, through: :assignments, class_name: 'Humanity::Role'

      base.validates_presence_of :username
      base.validates_uniqueness_of :username
    end

    def name
      "#{first_name} #{last_name}".strip
    end

    def role_symbols
      roles.map(&:to_sym)
    end

    def has_role?(role)
      roles.where(name: role.to_s).first.present?
    end

    def admin?
      has_role? :admin
    end

    def developer?
      has_role? :developer
    end

    def update_roles!(role_names, source)
      prev_roles = self.roles
      new_roles = role_names.map { |n| Role.find_or_create_by_name(n) }

      # Create new roles and/or update source
      new_roles.each do |role|
        assignment = Assignment.find_or_initialize_by_human_id_and_human_type_and_role_id(self.id, self.class.to_s, role.id)
        assignment.source = source
        assignments << assignment if assignment.changed?
      end

      # Remove roles we had but don't anymore
      old_roles = (prev_roles - new_roles)
      assignments.each do |a|
        a.destroy if old_roles.include?(a.role) && a.source == source
      end

      roles.reload
    end

    def update_login_info!
      self.last_login_at = current_login_at
      self.current_login_at = Time.now
      self.login_count = login_count.to_i + 1
      self.save
    end

    def to_s
      name
    end
  end
end