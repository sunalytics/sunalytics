module Sunalytics
  class SchemaReader

    def get_schema
      Rails.application.eager_load!

      ActiveRecord::Base.descendants.map do |model|
        columns_hash = {}

        begin
          model.columns_hash.each {|k,v| columns_hash[v.name] = v.type}
          {
            name: model.name,
            table_name: model.table_name,
            primary_key: model.primary_key,
            columns: columns_hash,
            associations: associations_for(model)
          }
        rescue Exception => e
          log(e)
        end
      end.compact
    end

    ACTIVE_RECORD_SCOPES = %w(
      after_add_for
      before_add_for
      after_remove_for
      before_remove_for
      attribute_aliases
      _
    )

    DUMMY_PARAMS = [
      [],
      ['first'],
      ['first', 'second'],
      ['first', 'second', 'third'],
      ['first', 'second', 'third', 'forth'],
      ['first', 'second', 'third', 'forth', 'fifth'],
      ['first', 'second', 'third', 'forth', 'fifth', 'sixth']
    ]

    def get_scopes(model)
      return unless model
      model = model.constantize
      methods = []

      model.methods(false).each do |method|
        unless method.to_s.send(:start_with?, *ACTIVE_RECORD_SCOPES)
          params = model.method(method).parameters
          params = params.select {|p| [:req, :opt].include? p[0] }
          begin
            if model.send(method, *DUMMY_PARAMS[params.count]).kind_of? ActiveRecord::Relation
              methods << {
                name: method,
                param_count: params.count,
                params: params
              }
            end
          rescue Exception => e
            log(e)
          end
        end
      end
      methods
    end


    private

    def associations_for(model)
      model.reflect_on_all_associations.map do |association|
        begin
          {
            name: association.name,
            type: association.macro,
            plural_name: association.plural_name,
            collection: association.collection?,
            foreign_key: (association.foreign_key if association.source_reflection),
            options: {
              class_name: (association.klass.name.to_s unless association.options[:polymorphic]),
              join_table: association.options[:join_table],
              through: association.options[:through],
              polymorphic: association.options[:polymorphic],
              as: association.options[:as]
            }
          }
        rescue Exception => e
          log(e)
        end
      end.compact
    end

    def log(exception)
      Rails.logger.info "sunalytics: #{exception.message}"
      nil
    end

  end
end
