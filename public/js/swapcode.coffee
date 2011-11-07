App =
	start: ->
		$('select').chosen()
		App.delegate()
	
	delegate: ->
		$('.editor .button').click @send
	
	send: (e) ->
		e.preventDefault()
		src = 
			id:         $('html').data('_id')
			templ_lang: $('#select_template select').val()
			templ_code: $('.template').val()
			style_lang: $('#select_style select').val()
			style_code: $('.style').val()
			scrpt_lang: $('#select_script select').val()
			scrpt_code: $('.scripting').val()
		
		$.post '/', src, (res) ->
			r = JSON.parse res
			if r.url? && r.url.match(App.urlRegex)
				console.log r.url
				$('html').data('_id', r.id)
			else
				console.log r

	urlRegex: /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
		
$ App.start