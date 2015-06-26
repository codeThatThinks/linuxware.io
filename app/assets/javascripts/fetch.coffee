$(document).on 'ready page:load', ->
	element = $('pre[data-fetch-status]')

	poll = ->
		$.get element.data('fetch-status'), (status) ->
			if status.is_fetching or status.is_fetch_queued
				setTimeout poll, 2000
			if status.is_fetching
				$('#title').text 'Fetching packages...'
			else if status.is_fetch_queued
				$('#title').text 'Waiting for fetch to start...'
			else
				$('#title').text 'Fetch completed.'
			if status.is_fetch_queued
				element.text "Fetch has been queued."
			else
				element.text status.fetch_log
			return
		return

	setTimeout poll, 2000
	return