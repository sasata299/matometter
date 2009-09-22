class DictionaryController < ApplicationController
  def index
  end

  def create
    Dictionary.create!(params[:dictionary])
    redirect_to :action => 'index'
  end
end
