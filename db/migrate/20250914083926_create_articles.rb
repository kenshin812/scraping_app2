class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.text :summary
      t.integer :risk_score
      t.datetime :published_at
      t.string :source_url

      t.timestamps
    end
  end
end
