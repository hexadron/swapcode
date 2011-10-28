require 'active_support'
require 'coffee-script'
require 'haml'
require 'sass'
require 'less'

class SwapCode < Sinatra::Application
  
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
      if params[:css_lang] == "sass"
        begin
          css = Sass.compile(params[:css_code], {:syntax => "sass"})
        rescue => err
          errors[params[:css_lang]] = err.to_s
        end
      else
        begin
          css = Less::Parser.new.parse(params[:css_code]).to_css(:compress => true)
        rescue => err
          errors[params[:css_lang]] = err.to_s
        end
      end
    end
    
    if errors.length > 0
      ActiveSupport::JSON.encode(errors)
    else
      unless params[:haml] == ""
        content = build_html({:html => html, :css => css, :js => js})
      else
        content = ""
      end      
      if params[:id]
        u = Url.find_by_id(params[:id])
        u.content = content
        u.save
      else
        u = Url.new({:content => content})
        u.save
      end
      id_and_url = { :id => u.id, :url => "#{base_url}/view/#{u.url}"}
      ActiveSupport::JSON.encode(id_and_url)
    end
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
  
end