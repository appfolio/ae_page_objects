# This migration comes from forum (originally 20141012015557)
class CreateForumPosts < ActiveRecord::Migration
  def change
    create_table :forum_posts do |t|
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
