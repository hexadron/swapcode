$ ->
	# bad code, this must be in html but i can't with haml and freak indentation in textareas
	
	$('#sass textarea').val "body\n\tbackground-color: hsl(0, 0, 0)\n\tcolor: hsl(0, 0, 100)"
	$('#haml textarea').val "!!! 5\n%html\n\t%head\n\t%body\n\t\t%h1 Say Hello"
	$('#coffee textarea').val "$ -> $('h1').append ', and wave goodbye'"
	
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
			