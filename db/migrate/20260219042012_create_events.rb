class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :start_datetime, null: false
      t.datetime :end_datetime
      t.text :description
      t.boolean :all_day, null: false, default: false

      t.timestamps
    end

    add_index :events, [:user_id, :start_datetime]
  end
end
