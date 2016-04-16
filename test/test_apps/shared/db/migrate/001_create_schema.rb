class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :indices do |t|
      t.integer :lock_version
      t.integer :pages
      t.belongs_to :book
    end

    create_table :books do |t|
      t.integer :lock_version
      t.belongs_to :author
      t.string :title
      t.timestamps
    end
    
    create_table :authors do |t|
      t.integer :lock_version
      t.string :suffix
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end
end
