class Framework < ActiveRecord::Base
  has_attached_file :png, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :png, content_type: ['image/jpeg', 'image/gif', 'image/png', 'image/svg+xml', 'text/plain']
  has_many :framework_molecules
  has_many :molecules, through: :framework_molecules
  belongs_to :user
  after_save :url_update
  
  def url_update
    self.update_column(:iza_url, "https://europe.iza-structure.org/IZA-SC/framework.php?STC=#{code}")
    self.update_column(:png_url, self.png.url)
  end
  


end
