$(document).ready ->
  softwares = new Bloodhound(
    queryTokenizer: Bloodhound.tokenizers.whitespace
    datumTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/software/search/%QUERY'
      wildcard: '%QUERY')
  $('.typeahead-softwares').typeahead { highlight: true },
    name: 'softwares'
    source: softwares
  return