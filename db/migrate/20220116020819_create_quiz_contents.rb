class CreateQuizContents < ActiveRecord::Migration[6.1]
  def change
    create_table :quiz_contents do |t|
      t.references :content, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true

      t.timestamps
    end
  end
end
