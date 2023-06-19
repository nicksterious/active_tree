# frozen_string_literal: true
module ActiveTree::Statusable

    extend ActiveSupport::Concern

    included do
        scope :active, -> { where(status: 1) }
        scope :inactive, -> { where(status: 0) }
	alias_method :enabled?, :active?
	alias_method :enable!, :active!
	alias_method :on!, :active!
	alias_method :disabled?, :inactive?
	alias_method :disable!, :inactive!
	alias_method :off!, :inactive!
	alias_method :toggle?, :toggle_status!
	
	before_create :set_default_status
    end

    def set_default_status
	self.status ||= 1
    end

    def toggle_status!
        if active?
            inactive!
        else
            active!
        end
    end

    def status?
	    [:inactive, :active][ status ]
    end

    def active?
        status == 1
    end
    def inactive?
        status == 0
    end

    def active!
        self.update(status: 1)
    end
    def inactive!
        self.update(status: 0)
    end
end
