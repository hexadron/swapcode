require 'sinatra'
require 'sinatra/activerecord'

class SwapCode < Sinatra::Application
  
  set     :database_extras, {:pool => 20, :timeout => 3000}
  set     :database, (ENV['DATABASE_URL'] or 'mysql2://root:@localhost/swapcode')
  enable  :sessions
  
  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
  end
  
end

require_relative 'models/init'
require_relative 'routes/init'