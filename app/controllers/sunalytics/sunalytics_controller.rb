require 'sunalytics/schema_reader'
require 'sunalytics/query_runner'

module Sunalytics
  class SunalyticsController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => :run_query

    before_filter :authenticate

    def database_type
      type = ActiveRecord::Base.connection.instance_values["config"][:adapter]
      render :json => {database_type: type}
    end

    def schema
      schema_hash = Sunalytics::SchemaReader.new.get_schema
      render :json => schema_hash
    end

    def scopes
      scopes = Sunalytics::SchemaReader.new.get_scopes(params[:model_name])
      render :json => scopes
    end

    def all_scopes
      models = [
        "Spree::Order",
        "Spree::User",
        "Spree::Role",
        "Spree::OptionValue",
        "Spree::Product",
        "Spree::Variant",
        "Spree::LineItem",
        "Spree::Shipment",
        "Spree::ProductOptionType",
        "Spree::ProductProperty",
        "Spree::Classification",
        "Spree::StockItem",
        "Spree::ShippingRate"
      ]
      scopes = {}
      models.each do |model|
        scopes[model] = Sunalytics::SchemaReader.new.get_scopes(model)
      end
      if scopes
        render :json => scopes
      else
        render :json => "Error in data retrieval"
      end

    end

    def run_query
      main_query = params[:query].deep_symbolize_keys
      pre_queries = params[:pre_queries].map do |query|
        query.deep_symbolize_keys
      end if params[:pre_queries]

      result = Sunalytics::QueryRunner.new.run(main_query, pre_queries)
      render json: result
    end

  protected

    # Enable HTTP basic authentication
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['SUNALYTICS_USER'] && password == ENV['SUNALYTICS_PASSWORD']
      end
    end


  end
end