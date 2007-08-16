class RailfrogToVersion6 < ActiveRecord::Migration
  def self.up
    Rails.plugins["railfrog"].migrate(6)
  end

  def self.down
    Rails.plugins["railfrog"].migrate(0)
  end
end
