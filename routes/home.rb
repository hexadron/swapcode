require 'active_support'
require 'coffee-script'
require 'haml'
require 'sass'
require 'less'

class SwapCode < Sinatra::Application
  
  get '/' do
    haml :index
  end
  
  get '/app' do
    haml :app
  end

  post '/' do
    errors = {}
    
    if params[:haml] != ""
      begin
        html = template(params[:templ_lang], params[:templ_code])
      rescue => err
        errors[params[:templ_lang]] = err.to_s
      end
      begin
        js = script(params[:scrpt_lang], params[:scrpt_code])
      rescue => err
        errors[params[:scrpt_lang]] = err.to_s
      end
      begin
        css = style(params[:style_lang], params[:style_code])
      rescue => err
        errors[params[:style_lang]] = err.to_s
      end
    end
    
    if errors.length > 0
      ActiveSupport::JSON.encode(errors)
    else
      if params[:templ_code].empty?
        content = ""
      else
        content = build_html(html, css, js)
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
  
  def template(lang, code)
    case lang
    when 'html'
      code
    when 'haml'
      Haml::Engine.new(code).render
    end
  end
  
  def script(lang, code)
    case lang
    when 'javascript'
      code
    when 'coffeescript'
      CoffeeScript.compile(code)
    end
  end

  def style(lang, code)
    case lang
    when 'css'
      code
    when 'sass'
      Sass.compile(code, {:syntax => "sass"})
    when 'less'
      Less::Parser.new.parse(code).to_css(:compress => true)
    end
  end
  
  def build_html html, css, js
    js_pos  = html.index('</body>')
    with_js = append_at html, js_pos, 
      "<script type='text/javascript' src='http://code.jquery.com/jquery.min.js'></script>
      <script type='text/javascript'>#{js}</script>"
    css_pos = with_js.index('</head>')
    
    append_at(with_js, css_pos, "<style>#{css}</style>")
  end
  
  def append_at(source, pos, what)
    pre = source[0..pos - 1]
    post = source[pos..source.length]
    
    "#{pre}#{what}#{post}"
  end
  
end