class AssayType < ActiveRecord::Base

  include PgSearch
  pg_search_scope :search_by_names,
                against: :names,
                using: {
                  tsearch: {dictionary: "english",
                            any_word: true,
                            prefix: true}
                }


end
