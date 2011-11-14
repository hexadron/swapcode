App =
  start: ->
    $('select').chosen()
    App.fill()
    App.launchEditors()
    App.delegate()
 
  modes:
    Html:   require("ace/mode/html").Mode
    Sass:   require("ace/mode/scss").Mode
    Js:     require("ace/mode/javascript").Mode
    Coffee: require("ace/mode/coffee").Mode

  launchEditors: ->
    App.template = ace.edit('templ_editor')
    App.style = ace.edit('style_editor')
    App.script = ace.edit('script_editor')

    App.template.getSession().setMode(new App.modes.Html())
    App.style.getSession().setMode(new App.modes.Sass())
    App.script.getSession().setMode(new App.modes.Coffee())

    [App.template, App.style, App.script].map (e) ->
      e.setTheme('ace/theme/dawn')

  fill: ->
    $('#templ_editor').text("""
      !!! 5
      %html
        %head
        %body
          %h1 Hey!
    """)
    $('#style_editor').text("""
      $size: 72px

      body
        background-color: hsl(350, 80, 60)
        color: hsl(0, 0, 95)

      h1
        font: $size 'Comic Sans MS'

      h2
        font: $size / 2 'Monaco'
    """)
    $('#script_editor').text("$ -> setTimeout (-> $('body').append '<h2>It works!</h2>'), 1200")
	
  delegate: ->
    $('.editor .button').click @send
    $('select').change @swapSyntax
    $('#open a').click @openUrl
	
  send: (e) ->
    e.preventDefault()
    
    src = 
      id:         $('html').data('_id')
      templ_lang: $('#select_template select').val()
      templ_code: App.template.getSession().getValue()
      style_lang: $('#select_style select').val()
      style_code: App.style.getSession().getValue()
      scrpt_lang: $('#select_script select').val()
      scrpt_code: App.script.getSession().getValue()

    $.post '/page/create', src, (res) ->
      r = JSON.parse res
      if r.url? && r.url.match(App.urlRegex)
        App.showLink(r.url)
        App.changeButton()
        $('html').data('_id', r.id)
      else
        App.showErrors(r)
  
  changeButton: ->
    $('.editor .button').text('Update')

  showLink: (link) ->
    $('#errors p.errs').text("")
    $('#errors h1').fadeOut('fast')
    $('.link a').attr('href', link).text(link)
    $('.link').css('visibility', 'visible')

  showErrors: (errors) ->
    $('#errors h1').fadeIn('fast')
    $('#errors p.errs').text("")
    $('#errors p.errs').append "#{e}: #{errors[e]}<br>" for e of errors
  
  openUrl: (e) ->
    e.preventDefault()
    url = $('#open input').val()
    return null unless url.match(App.urlRegex)
    
    $.get '/page/open', {url: url}, (res) ->
      r = JSON.parse(res)
      if r.page?
        p = r.page
        App.openPage(p)
      else
        console.log r
  
  openPage: (p) ->
    $('html').data('_id', p.id)
    $('#select_template select').val p.templ_lang
    App.template.getSession().setValue p.templ_code
    $('#select_style select').val p.style_lang
    App.style.getSession().setValue p.style_code
    $('#select_script select').val p.script_lang
    App.script.getSession().setValue p.script_code
    App.showLink p.url

  swapSyntax: (e) ->
    switch e.target.value
      when 'javascript'
        App.script.getSession().setMode(new App.modes.Js())
      when 'coffeescript'
        App.script.getSession().setMode(new App.modes.Coffee())

  urlRegex: /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/

$ App.start