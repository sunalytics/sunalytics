module Sunalytics
  class QueryRunner

    def run(query, pre_queries = nil)
      where_condition = build_where_condition(pre_queries) if pre_queries

      base = query[:model_name].constantize
      base = base.where(where_condition) if where_condition
      base = base.where(convert_if_range(query[:where], query[:model_name].constantize)) if query[:where]

      if query[:scopes]
        query[:scopes].keys.each do |scope|
          base = base.send(scope)
        end
      end

      base = base.group(query[:group_by]) if query[:group_by]
      base = base.limit(query[:limit]) if query[:limit]
      base = base.reorder(query[:order]) if query[:order]
      base = base.calculate(query[:calculate][:operator], query[:calculate][:on_column].to_sym) if query[:calculate]
      base = base.pluck(:id) if query[:pluck]
      if base.kind_of? ActiveRecord::Relation
        base = base.map(&:serializable_hash)
      end

      {
        result: base,
        result_mapping: mapping(base, query),
        where_condition: where_condition
      }.to_json

    end

  private

    def build_where_condition(pre_queries)
      query_result = nil

      pre_queries.each do |query|
        base = query[:model_name].constantize if query[:model_name]

        if query[:where]
          if query[:where] == "query_result"
            base = base.where(query_result)
          else
            base = base.where(convert_if_range(query[:where], base))
          end
        end

        if query[:scopes]
          query[:scopes].keys.each do |scope|
            base = base.send(scope)
          end
        end

        base = base.pluck(query[:pluck].to_sym).uniq if query[:pluck]
        base = query[:query_value] if query[:query_value]
        base = { query[:query_key] => base } if query[:query_key]

        query_result = base
      end

      query_result
    end

    def convert_if_range(where, model=nil)
      where.each do |column, value|
        where[column] = value = Array(value)

        value.each_with_index do |sub_value, index|
          next unless sub_value.is_a? String

          if sub_value == '' and model
            if [:string, :text].include? model.columns_hash[column].try(:type)
              where[column] << nil
            else
              where[column][index] = nil
            end
          elsif sub_value.include?('...')
            parts = sub_value.split('...')
            where[column][index] = Range.new(parts[0], parts[1], true)
          elsif sub_value.include?('..')
            parts = sub_value.split('..')
            where[column][index] = Range.new(parts[0], parts[1])
          end
        end
      end
    end

    def mapping(base, query)
      return unless query[:reference_model] and query[:reference_column]
      query[:reference_model].constantize.
        where('id' => base.keys).
        select('id', query[:reference_column]).inject({}) do |hash, row|
          hash[row['id']] = row[query[:reference_column]]
          hash
        end
    end

  end
end
