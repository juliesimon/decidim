# frozen_string_literal: true

module Decidim
  # This interface represents an author who owns a resource.
  AuthorInterface = GraphQL::InterfaceType.define do
    name "Author"
    description "An author"

    field :name, !types.String, "The author's name"
    field :nickname, !types.String, "The author's nickname"

    field :avatarUrl, !types.String, "The author's avatar url"
    field :profilePath, !types.String, "The author's profile path"
    field :badge, !types.String, "The author's badge icon"

    field :deleted, !types.Boolean, "Whether the author's account has been deleted or not"

    resolve_type lambda { |_type, obj, _ctx|
                   return Decidim::UserType if obj.is_a? Decidim::User
                   return Decidim::UserGroupType if obj.is_a? Decidim::UserGroup
                 }
  end
end
