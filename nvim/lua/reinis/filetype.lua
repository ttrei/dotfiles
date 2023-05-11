vim.filetype.add({
  pattern = {
    ['.*%.html'] = 'html',
    ['.*%.html.j2'] = 'html',
    ['.*%.html.jinja2'] = 'html',
  },
})
