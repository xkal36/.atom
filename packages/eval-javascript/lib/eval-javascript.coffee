coffee = require 'coffee-script'
vm = require 'vm'


module.exports =

  activate: ->
    @disposable = atom.commands.add 'atom-text-editor', 'eval-javascript:eval-javascript', =>
      atom.openDevTools()
      editor = atom.workspace.getActiveTextEditor()
      if !editor
        console.warn "No text editor is active."
        return
      code = editor.getSelectedText()
      if code
        scope = @matchingCursorScopeInEditor(editor)
      else
        return console.error "No code selected"
      @runCodeInScope code, scope, (error, warning, result) ->
        if error
          console.error error.toString().replace(/evalmachine.\S*/,'')
        else if warning
          console.warn warning
        else
          console.log ">", result

  deactivate: ->
    @disposable?.dispose()

  runCodeInScope: (code, scope, callback) ->
    switch scope
      when 'source.coffee'
        try
          result = vm.runInThisContext(coffee.compile(code, bare: true))
          callback(null, null, result)
        catch error
          callback(error)
      else
        try
          result = vm.runInThisContext(code)
          callback(null, null, result)
        catch error
          callback(error)

  matchingCursorScopeInEditor: (editor) ->
    for scope in ['source.coffee', 'source.js', 'source.js.embedded.html']
      return scope if scope in editor.getLastCursor().getScopeDescriptor().scopes

  scopeInEditor: (editor) ->
    editor.getGrammar()?.scopeName
