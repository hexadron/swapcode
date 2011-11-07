App =
	start: ->
		$('select').chosen()
		App.fill().launchEditors().delegate()
	
	modes:
		Html: 	require("ace/mode/html").Mode
		Sass: 	require("ace/mode/scss").Mode
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
			
		this
	
	fill: ->
		$('#templ_editor').text("!!! 5\n%html\n    %head\n    %body\n        %h1 Say Hello")
		$('#style_editor').text("body\n  background-color: hsl(0, 0, 0)\n  color: hsl(0, 0, 100)")
		$('#script_editor').text("$ -> $('h1').append ', and wave goodbye'")
		
		this
	
	delegate: ->
		$('.editor .button').click @send
	
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
		
		$.post '/', src, (res) ->
			r = JSON.parse res
			if r.url? && r.url.match(App.urlRegex)
				App.showLink(r.url)
				$('html').data('_id', r.id)
			else
				App.showErrors(r)
	
	showLink: (link) ->
		$('.link a').attr('href', link).text('here')
		$('.link').css('visibility', 'visible')
		
	showErrors: (errors) ->
		$('#errors h1').fadeIn('fast')
		$('#errors p.errs').text("")
		$('#errors p.errs').append "#{e}: #{errors[e]}<br>" for e of errors
		
		
		
	urlRegex: /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
		
$ App.start