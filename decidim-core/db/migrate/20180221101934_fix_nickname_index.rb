# frozen_string_literal: true

class FixNicknameIndex < ActiveRecord::Migration[5.1]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  def change
    Decidim::User.where(nickname: nil).update_all("nickname = NULL")
    change_column_default :decidim_users, :nickname, ""
    change_column_null(:decidim_users, :nickname, false)
  end
end
