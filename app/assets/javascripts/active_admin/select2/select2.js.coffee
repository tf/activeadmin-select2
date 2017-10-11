'use strict';

initSelect2 = (inputs, extra = {}) ->
  inputs.each ->
    item = $(this)
    # reading from data allows <input data-select2='{"tags": ['some']}'> to be passed to select2
    options = $.extend(allowClear: true, extra, item.data('select2'))
    url = item.data('ajaxUrl');

    if url
      $.extend(
        options,
        ajax: {
          url: url,
          dataType: 'json'
        }
      )

    # because select2 reads from input.data to check if it is select2 already
    item.data('select2', null)
    item.select2(options)

    if url && item.data('selectedValue')
      $.ajax({
        type: 'GET',
        dataType: 'json',
        url: url + '?q[id_eq]=' + item.data('selectedValue')
      }).then((data) ->
        if data.results.length
          data = data.results[0]
          option = new Option(data.text, data.id, true, true)
          item.append(option).trigger('change')
      )

$(document).on 'has_many_add:after', '.has_many_container', (e, fieldset) ->
  initSelect2(fieldset.find('.select2-input'))

$(document).on 'ready page:load turbolinks:load', ->
  initSelect2($(".select2-input"), placeholder: "")
  return
