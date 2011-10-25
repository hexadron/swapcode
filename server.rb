require_relative 'models'

# TODO, cada actualización crea un link nuevo o_o

require 'active_support'
require 'coffee-script'
require 'haml'
require 'sinatra'
require 'sass'

set :database_extras, {:pool => 20, :timeout => 3000}
set :database, (ENV['DATABASE_URL'] or 'postgres://postgres:syd@localhost:5433/swapcode')

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end

# Routes/Controller

get '/' do
  haml :index
end

post '/' do
  errors = {}
  unless params[:haml] == ""
    begin
      html = Haml::Engine.new(params[:haml]).render
    rescue => err
      errors[:haml] = err.to_s
    end
    begin
      js  = CoffeeScript.compile(params[:coffee])
    rescue => err
      errors[:coffeescript] = err.to_s
    end
    begin
      css = Sass.compile(params[:sass], {:syntax => "sass"})
    rescue => err
      errors[:sass] = err.to_s
    end
  end
  
  if errors.length > 0
    ActiveSupport::JSON.encode(errors)
  else
    content = params[:haml] != "" \
      ? build_html({:html => html, :css => css, :js => js}) \
      : ""
    if params[:id]
      u = Url.find_by_id(params[:id])
      u.content = content
      u.save
    else
      u = Url.new({:content => content})
      u.save
      puts "%%" * 100
      puts u.id
      puts "%%" * 100
    end
    id_and_url = { :id => u.id, :url => "#{base_url}/view/#{u.url}"}
    ActiveSupport::JSON.encode(id_and_url)
  end
end

get '/view/:url' do
  page = Url.select('content, url').where(:url => params[:url]).first
  
  page.nil?? haml(:index) : page.content
end

def build_html page
  js_pos  = page[:html].index('</body>')
  with_js = append_at page[:html], js_pos, 
    "<script type='text/javascript' src='http://code.jquery.com/jquery.min.js'></script>
    <script type='text/javascript'>#{page[:js]}</script>"
    
  css_pos = with_js.index('</head>')
  append_at(with_js, css_pos, "<style>#{page[:css]}</style>")
end

def append_at(source, pos, what)
  pre = source[0..pos - 1]
  post = source[pos..source.length]
  
  "#{pre}#{what}#{post}"
end