class User < ApplicationRecord
  validates :user_id,
            presence: { message: "Required user_id and password" },
            length: { in: 6..20, message: "Input length is incorrect" },
            format: { with: /\A[a-zA-Z0-9]+\z/, message: "Incorrect character pattern" },
            on: :create

  validates :password,
            presence: { message: "Required user_id and password" },
            length: { in: 8..20, message: "Input length is incorrect" },
            format: { with: /\A[\x21-\x7E]+\z/, message: "Incorrect character pattern" },
            on: :create
end
