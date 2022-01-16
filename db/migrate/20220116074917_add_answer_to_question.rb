class AddAnswerToQuestion < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :answer, :text, default: 'Unknown'
  end
end
