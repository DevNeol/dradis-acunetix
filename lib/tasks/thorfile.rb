class AcunetixTasks < Thor
  include Rails.application.config.dradis.thor_helper_module
  
  namespace "dradis:plugins:acunetix"

  desc "upload FILE", "upload Acunetix XML results"
  def upload(file_path)
    require 'config/environment'

    unless File.exists?(file_path)
      $stderr.puts "** the file [#{file_path}] does not exist"
      exit -1
    end

    detect_and_set_project_scope
    importer = Dradis::Plugins::Acunetix::Importer.new(task_options)
    importer.import(file: file_path)
  end

end
