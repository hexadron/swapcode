class SwapCode < Sinatra::Application
  
  get '/' do
    haml :index
  end
  
  get '/app' do
    haml :app
  end
  
end