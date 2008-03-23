class RailfrogToVersion6 < ActiveRecord::Migration
  def self.up
    Engines.plugins["railfrog"].migrate(6)
  end

  def self.down
    Engines.plugins["railfrog"].migrate(0)
  end
end
