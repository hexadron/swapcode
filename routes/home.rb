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
    return "" if params[:templ_code].empty?
    
    get_web params do |code, errors|
      return ActiveSupport::JSON.encode(errors) if errors.length > 0
      
      page = if params[:id]
        p = Page.find_by_id(params[:id])
        p.content = code
        p
      else
        Page.new({:content => code})
      end
      
      page.save
      jstring = {id: page.id, url: "#{base_url}/view/#{page.url}"}

      return ActiveSupport::JSON.encode(jstring)
    end
  end
  
  def get_web data
    errs = {}
    
    html = handle errs, params[:templ_lang] { template(params[:templ_lang], params[:templ_code]) }
    css  = handle errs, params[:style_lang] { style(params[:style_lang], params[:style_code]) }
    js   = handle errs, params[:scrpt_lang] { script(params[:scrpt_lang], params[:scrpt_code]) }
    
    content = build_html html, css, js
    
    yield content, errs
  end
  
  def handle errs, type
    begin
      yield
    rescue => e
      errs[type] = e.to_s
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