class DocSection < DocItem

  def items
    @items ||= load_items
  end

  def find(id)
    items.find {|item| item.id == id }
  end

  def self.all(language = 'en', force = false)
    if force
      @all = nil
    end
    @all ||= {}
    @all[language] ||= load_dirs(language)
  end

  def self.find(id, language = 'en', force = false)
    if id.blank?
      root(language)
    else
      all(language, force).find {|item| item.id == id }
    end
  end

  def self.root(language = 'en')
    @root ||= {}
    @root[language] ||= load(File.join(RAILS_ROOT, 'doc', 'noosfero'), language)
  end

  private

  attr_accessor :directory

  def self.load_dirs(language)
    Dir.glob(File.join(RAILS_ROOT, 'doc', 'noosfero', '*')).select {|item| File.directory?(item) }.map do |dir|
      load(dir, language)
    end
  end

  def self.load(dir, language)
    index = DocTopic.loadfile(self._find_topic(dir, 'index', language))
    toc = DocTopic.loadfile(self._find_topic(dir, 'toc', language))
    new(:id => File.basename(dir), :title => index.title, :text => index.text + toc.text, :language => language, :directory => dir)
  end

  def self._find_topic(dir, id, language)
    language_suffix = _language_suffix(language)
    [
      File.join(dir, "#{id}#{language_suffix}.xhtml"),
      File.join(dir, "#{id}.en.xhtml")
    ].find {|file| File.exist?(file) }
  end

  def load_items
    if directory
      language_suffix = self.class._language_suffix(language)
      Dir.glob(File.join(directory, "*.en.xhtml")).map do |file|
        # extract the available id's from the English versions
        File.basename(file).sub(/\.en.xhtml$/, '')
      end.map do |id|
        # load a translation, if available, or the original English topic
        DocTopic.loadfile(self.class._find_topic(directory, id, language))
      end
    else
      []
    end
  end

  def self._language_suffix(language)
    (!language || language == 'en') ? '' : ('.' + language)
  end


end
