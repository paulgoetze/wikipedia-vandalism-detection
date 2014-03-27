module FileReading

  def load_file(file_name)
    ressources_path = File.expand_path("../../../resources", __FILE__)
    File.read("#{ressources_path}/#{file_name}")
  end
end