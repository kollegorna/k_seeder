require "faker"
require "k_seeder/version"
require "k_seeder/content"

# rake tasks
require "tasks/seeder"

module KSeeder
  def self.seed(class_name, entries)
    # only accepting base level classes
    return false if class_name.include?('::')

    model_class = class_name.constantize
    puts "Creating #{entries} #{model_class.to_s} instances..."

    # seeding x instances of the model
    (1..entries).each do |index|
      model = model_class.new
      model_class.columns.each do |field|
        # filling each column by according to the column name/type
        content = KSeeder::Content.new(model_class, field).fill
        model[field.name] = content
      end
      model.save
    end
  end
end
