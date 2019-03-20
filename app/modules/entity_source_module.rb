# frozen_string_literal: true

module EntitySourceModule
  extend ActiveSupport::Concern
  ENTITY_SOURCES = (ENV['ENTITY_SOURCES'] || 'Midtrans').split(',').map!(&:capitalize)

  included do
    validates :entity_source, presence: true
    comma :entity_source do
      entity_source "Entity source"
    end
  end

end
