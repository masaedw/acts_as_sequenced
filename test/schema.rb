ActiveRecord::Schema.define(:version => 1) do

  create_table :two_ch_threads, :force => true do |t|
    t.string :title, :limit => 50
    t.integer :th_no
  end

  create_table :responses, :force => true do |t|
    t.string :two_ch_thread_id
    t.integer :response_no
    t.string :content
    t.timestamp :deleted_at
  end

end
