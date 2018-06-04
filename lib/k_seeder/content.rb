class KSeeder::Content

  def initialize(model, field)
    @model = model
    @field = field
  end

  def fill
    return nil if ['id', 'created_at', 'updated_at'].include?(@field.name)

    return fill_from_validations if has_validations?

    # first checking if it's a fk
    return fill_from_fk if is_fk? # TODO

    # after checking if it's an enum
    return fill_from_enum if is_enum?

    # trying to fill field based on its name
    content = fill_from_name
    return content unless content.nil?

    # finally filling content based on its type
    fill_from_type
  end

  def fill_from_validations
    return nil unless has_validations?
    validation = @model.validators_on(@field.name).find { |v| !v.options[:in].nil? }

    # returning a sample from the validation options
    validation.options[:in].sample
  end

  def fill_from_enum
    return nil unless is_enum?
    @model.defined_enums[@field.name].values.sample
  end

  def fill_from_fk
    return nil unless is_fk?

    fk = @model.reflect_on_all_associations.find { |c| c.foreign_key == @field.name }
    fk_class = fk.name.to_s.classify.constantize
    fk_class.pluck(:id).sample
  rescue NameError
    # unexistant fk class
    nil
  end

  def fill_from_name
    case @field.name
    when 'name'
      # first checking for class name
      case @model.to_s
      when 'User'
        Faker::Name.name
      when 'City'
        Faker::Address.city
      when 'Company'
        Faker::Company.name
      when 'District'
      when 'State'
        Faker::Address.state
      else # defaulting to regular name
        Faker::Name.name
      end
    when 'email'
      Faker::Internet.email
    when 'first_name'
      Faker::Name.first_name
    when 'last_name'
      Faker::Name.last_name
    when 'phone_number'
      Faker::PhoneNumber.cell_phone
    end
  end

  def fill_from_type
    case @field.type
    when :string
      Faker::Lorem.characters(@field.limit || 10)
    when :integer
      Faker::Number.between(1, 100)
    when :float
      Faker::Number.decimal(2)
    when :boolean
      Faker::Boolean.boolean
    when :date
    when :datetime
      Faker::Date.backward(365)
    when :text
      Faker::Lorem.sentence
    when :jsonb
    end
  end

  private

  def is_enum?
    @model.defined_enums.has_key?(@field.name)
  end

  def is_fk?
    @model.reflect_on_all_associations.any? { |c| c.foreign_key == @field.name }
  end

  def has_validations?
    # TODO include another validations
    @model.validators_on(@field.name).any? { |v| !v.options[:in].nil? }
  end
end
