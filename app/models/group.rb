class Group < ActiveRecord::Base

  has_many :assignments
  has_many :users, through: :assignments
  before_save :refine_url
  validates :name, presence: true, uniqueness: true


  def group_interactions
    user_ids = users.map {|u| u.id}
    #interactions = Interaction.active.not_embargoed.where(user_id: user_ids)
    interactions = Interaction.active.where(user_id: user_ids)
  end

  def group_datasets
    datasets_ids = []
    users.each do |user|
      data = user.datasets.map(&:id)
      datasets_ids += data
    end
    datasets = Dataset.where(id: datasets_ids.uniq)
    return datasets
  end




  def group_interactions_size
    group_int_size=0
    for user in self.users do
      group_int_size=group_int_size+user.interactions.active.size
    end
    return group_int_size
  end

  def refine_url
    if self.website.present?
      result = self.website =~ URI::regexp
      unless result.present?
        self.website = "http://"+self.website
      end
    end
  end
end
