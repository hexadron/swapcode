class SwapCode < Sinatra::Application
  get '/view/:url' do
    page = Page.select('content, url').where(:url => params[:url]).first
    
    page.nil?? haml(:index) : page.content
  end
end