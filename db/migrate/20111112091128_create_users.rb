class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.text :password_digest
    end
    add_index :users, :username
  end

  def self.down
    drop_table :users
  end
end