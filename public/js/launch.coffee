$ ->
	# bad code, this must be in html but i can't with haml
	
	$('#sass textarea').val "body\n\tbackground-color: hsl(0, 0, 0)"
	$('#haml textarea').val "!!! 5\n%html\n\t%head\n\t%body\n\t\t%h1 Hola Mundo!"
	
	# end
	
	code = (lang) ->
		$("##{lang} textarea").val()
	
	$('#launch').click (e) ->
		e.preventDefault()
		
		source =
			haml: code 'haml'
			sass: code 'sass'
			coffee: code 'coffee',
			
		$.post '/', source, (url) ->
			if url is "error"
				alert "error"
			else
				alert url
			