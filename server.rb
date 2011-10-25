require 'digest/md5'
require 'alphadecimal'
require 'coffee-script'
require 'haml'
require 'sinatra'
require 'sinatra/activerecord'
require 'sass'
require 'pg'

set :haml, :format => :html5
set :database, (ENV['DATABASE_URL'] or 'postgres://postgres:syd@localhost:5433/swapcode')

class Url < ActiveRecord::Base
  after_initialize      :gen_url
  validates_presence_of :url
  
  def gen_url
    self.url = Digest::MD5.hexdigest(self.content)
    self
  end
end

# Routes/Controller

get '/' do
  haml :index
end

post '/' do
  js   = CoffeeScript.compile(params[:coffee])
  css  = Sass.compile(params[:sass], {:syntax => "sass"})
  html = Haml::Engine.new(params[:haml]).render
  
  build_html({:html => html, :css => css, :js => js})
end

get '/view/:url' do
  page = Url.where(:url => params[:url]).first
  if page.nil?
    haml :index
  else
    page.content
  end
end

def build_html page
  js_pos  = page[:html].index('</body>')
  with_js = append_at page[:html], js_pos, "<script type='text/javascript'>#{page[:js]}</script>"
    
  css_pos = with_js.index('</head>')
  content = append_at with_js, css_pos, "<style>#{page[:css]}</style>"
  
  u = Url.new({:content => content})
  if u.save
    "http://localhost:4567/view/#{u.url}"
  else
    "error"
  end
end

def append_at(source, pos, what)
  pre = source[0..pos - 1]
  post = source[pos..source.length]
  
  "#{pre}#{what}#{post}"
end