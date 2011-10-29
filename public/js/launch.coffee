$ ->
	
	# bad code, this must be in the html but i can't with haml and textarea's freak indentation
	
	$('#_css textarea').val "body\n\tbackground-color: hsl(0, 0, 0)\n\tcolor: hsl(0, 0, 100)"
	$('#haml textarea').val "!!! 5\n%html\n\t%head\n\t%body\n\t\t%h1 Say Hello"
	$('#coffee textarea').val "$ -> $('h1').append ', and wave goodbye'"
	
	# end
	
	# codemirror
	
	jseditor = CodeMirror.fromTextArea $('#coffee textarea')[0], 
		lineNumbers: true
	
	csseditor = 	CodeMirror.fromTextArea $('#_css textarea')[0], 
		lineNumbers: true

	htmleditor = 	CodeMirror.fromTextArea $('#haml textarea')[0], 
		lineNumbers: true

	$('#launch input').click (e) ->
		e.preventDefault()
		source =
			haml: htmleditor.getValue()
			css_lang: $('input[name=_css]:checked').val()
			css_code: csseditor.getValue()
			coffee: jseditor.getValue()
			id: $('html').data('_id')
			
		$.post '/', source, (res) ->
			exp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
			r = JSON.parse(res)
			if r.url.match(exp)
				$('#url_location').html("<a href='#{r.url}' target='_blank'>Open in New Tab</a>")
				$('iframe').attr 'src', r.url
				$('html').data('_id', r.id)
			else
				$('#url_location').addClass('error').html JSON.stringify(r)