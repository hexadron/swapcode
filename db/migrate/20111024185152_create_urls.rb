class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :url
      t.text   :content
      t.string :templ_lang
      t.text   :templ_code
      t.string :script_lang
      t.text   :script_code
      t.string :style_lang
      t.text   :style_code
    end
    add_index :pages, :url
  end

  def self.down
    drop_table :pages
  end
end