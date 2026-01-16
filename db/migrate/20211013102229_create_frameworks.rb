class CreateFrameworks < ActiveRecord::Migration
  def change
    create_table :frameworks do |t|
      t.belongs_to :user
      t.attachment :png
      t.text :png_url
      t.text :name
      t.text :code
      t.text :iza_url
      t.text :crystal_system
      t.text :space_group
      t.float :unit_cell_a
      t.float :unit_cell_b
      t.float :unit_cell_c
      t.float :unit_cell_alpha
      t.float :unit_cell_beta
      t.float :unit_cell_gamma
      t.float :volume
      t.float :rdls
      t.float :framework_density
      t.float :topological_density
      t.float :topological_density_10
      t.integer :ring_sizes, default: [], array: true
      t.text :channel_dimensionality
      t.float :max_d_sphere_included
      t.float :max_d_sphere_diffuse_a
      t.float :max_d_sphere_diffuse_b
      t.float :max_d_sphere_diffuse_c
      t.float :accessible_volume
      t.timestamps null: false
    end
  end
end
