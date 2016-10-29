require 'rails/generators'
class BottledServiceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :attributes, type: :array, default: []

  def generate_bottled_service
    puts "Generating Bottled Service: #{name}"
    create_file "app/services/#{file_name}.rb", <<-File
class #{class_name} < BottledService

  #{ "".tap do |str|
      attributes.each do |attribute|
        puts "injecting attribute: #{attribute.name}"
        if attribute.type.present?
          str << "att :#{attribute.name}, #{attribute.type}
  "
        else
          str << "att :#{attribute.name}
  "
        end
      end
    end
}

  def call
    # Do something...
    yield if block_given?
  end

end
    File
  end
end
