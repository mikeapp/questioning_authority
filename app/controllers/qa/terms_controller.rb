# This controller is used for all requests to all authorities. It will verify params and figure out
# which class to instantiate based on the "vocab" param. All the authotirty classes inherit from a
# super class so they implement the same methods.

class Qa::TermsController < ApplicationController

  before_action :check_vocab_param, :init_authority
  before_action :check_query_param, only: :search

  # If the subauthority supports it, return a list of all terms in the authority
  def index
    render json: @authority.all
  end

  # Return a list of terms based on a query
  def search
    terms = @authority.search(url_search)
    render json: terms
  end

  # If the subauthority supports it, return all the information for a given term
  def show
    term = @authority.find(params[:id])
    render json: term
  end

  def check_vocab_param
    head :not_found unless params[:vocab].present?
  end

  def init_authority
    @authority = authority_class.constantize.new(params[:sub_authority])
  rescue
    head :not_found
  end

  def check_query_param
    head :not_found unless params[:q].present?
  end

  private

  def authority_class
    "Qa::Authorities::"+params[:vocab].capitalize
  end

  # converts wildcards into URL-encoded characters
  def url_search
    params[:q].gsub("*", "%2A")
  end

end
