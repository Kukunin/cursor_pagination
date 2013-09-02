# require 'rails/all'
require 'action_controller/railtie'
require 'action_view/railtie'

require 'fake_app/active_record/config' if defined? ActiveRecord

# config
app = Class.new(Rails::Application)
app.config.secret_token = 'f47a93ac1ff6843777fed92f966d61dc'
app.config.session_store :cookie_store, :key => '_myapp_session'
app.config.active_support.deprecation = :log
app.config.eager_load = false
# Rais.root
app.config.root = File.dirname(__FILE__)
Rails.backtrace_cleaner.remove_silencers!
app.initialize!

# routes
app.routes.draw do
  resources :entities

  namespace :two_column do
    resources :entities
  end
end

#models
require 'fake_app/active_record/models' if defined? ActiveRecord

# controllers
class ApplicationController < ActionController::Base; end
class EntitiesController < ApplicationController

  def index
    @entities = Entity.order('custom ASC').cursor(params[:cursor], column: :custom).per(1)
    render :inline => %q/
    <%= previous_cursor_link(@entities, "Previous Page") %>
    <%= @entities.map { |n| "Custom #{n.custom}" }.join("\n") %>
    <%= next_cursor_link(@entities, "Next Page") %>/
  end

end

module TwoColumn
  class EntitiesController < ApplicationController
    def index
      @entities = Entity.order('custom_time DESC, id DESC').cursor(params[:cursor], columns: { custom_time: { reverse: true }, id: { reverse: true } }).per(1)
      render :inline => %q/
      <%= previous_cursor_link(@entities, "Previous Page") %>
      <%= @entities.map { |n| "Custom #{n.custom}" }.join("\n") %>
      <%= next_cursor_link(@entities, "Next Page") %>/
    end

  end
end

# helpers
Object.const_set(:ApplicationHelper, Module.new)
