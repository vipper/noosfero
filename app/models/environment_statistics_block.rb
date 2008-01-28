class EnvironmentStatisticsBlock < Block

  def self.description
    _('Statitical overview of your environment.')
  end

  def content
    users = owner.people.count
    enterprises = owner.enterprises.count

    info = [
      n_('One user', '%{num} users', users) % { :num => users },
      n_('One enterprise', '%{num} enterprises', enterprises) % { :num => enterprises}
    ]

    content_tag('h3', _('Statistics for  %s') % owner.name, :class => 'block-title' ) + content_tag('ul', info.map {|item| content_tag('li', item) }.join("\n"))
  end

end
