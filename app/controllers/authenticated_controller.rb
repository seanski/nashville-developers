class AuthenticatedController < ApplicationController
  before_filter :authenticate_user!
  check_authorization
end
