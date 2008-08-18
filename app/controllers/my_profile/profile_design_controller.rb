class ProfileDesignController < BoxOrganizerController

  needs_profile

  protect 'edit_profile_design', :profile
  
  def available_blocks
    blocks = [ ArticleBlock, TagsBlock, RecentDocumentsBlock, ProfileInfoBlock, LinkListBlock ]

    # blocks exclusive for organizations
    if profile.has_members?
      blocks << MembersBlock
    end

    # blocks exclusive to person
    if profile.person?
      blocks << FriendsBlock
      blocks << FavoriteEnterprisesBlock
      blocks << MyNetworkBlock
    end

    # product block exclusive for enterprises in environments that permits it
    if profile.enterprise? && !profile.environment.enabled?('disable_products_for_enterprises')
      blocks << ProductsBlock
    end

    blocks
  end

end
