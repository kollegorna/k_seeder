namespace :seeder do
  desc 'Seeds all models'
  task :seed, [:model] => :environment do |task, args|
    # defaulting to 10 entries if no value is provided
    entries = ENV['ENTRIES'].present? ? ENV['ENTRIES'].to_i : 10

    # if no models are received, all are consired
    if ENV['MODELS'].present?
      models = ENV['MODELS'].split(',')
      models.map! { |model| model.capitalize }
    else
      Rails.application.eager_load!
      models = ApplicationRecord.descendants.map { |model| model.to_s }
    end

    models.each do |model|
      KSeeder.seed(model, entries)
    end
  end
end
