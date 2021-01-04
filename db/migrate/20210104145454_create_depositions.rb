class CreateDepositions < ActiveRecord::Migration[6.0]
  def change
    create_table :depositions do |t|
      t.string :reason
      t.string :excuse
      t.string :dep_city
      t.string :arr_city
      t.datetime :departure, default: nil
      t.datetime :arrival, default: nil
      t.boolean :forward
      t.datetime :forward_dep, default: nil
      t.datetime :forward_arr, default: nil
      t.string :delay
      t.string :alert_date

      t.timestamps
    end
  end
end
