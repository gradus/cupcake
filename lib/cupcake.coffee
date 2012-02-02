eco = require 'eco'
fs = require 'fs'
ask = require('ask')

class Cupcake
  eco: eco
  fs: fs
  ask: ask

  VERSION: '0.2.1'

  ROOT: [
    'package.json'
    'app.js'
    'app.coffee'
    'readme.md'
    'Procfile'
  ]

  ARTIFACTS: 
    template:
      label: 'Template Engine'
      options: ['jade','eco', 'coffeekup']
    datastore:
      label: 'Data Store'
      options: ['request', 'mysql', 'mongoskin']
  
  project: 
    name: 'foobar'
    framework: 'express'
    template: 'jade'
    datastore: 'request'

  render_template: (name, project) ->
    template = @fs.readFileSync __dirname + "/../templates/#{name}.eco", "utf8"
    @fs.writeFileSync "./#{project.name}/#{name}", @eco.render(template, project)

  build_folders: ->
    @fs.mkdirSync directory, 0755 for directory in [
      "./#{@project.name}"
      "./#{@project.name}/views"
      "./#{@project.name}/public"
      "./#{@project.name}/public/stylesheets"
      "./#{@project.name}/public/javascripts"
    ]

  build_files: ->
    # Create Template Files
    @render_template(name, @project) for name in @ROOT
    template_name = if @project.template == 'coffeekup' then 'coffee' else @project.template

    @render_template(name, @project) for name in [
      "views/layout.#{template_name}"
      "views/index.#{template_name}"
    ]

  display_choices: (val) ->
    console.log "What #{val.label} would you like?"
    for j, option of val.options
      index = parseInt(j) + 1
      console.log "#{index}. #{option}"

  thank_you: ->
    console.log """
-----------------
Successfully created #{@project.name}
To Run
cd #{@project.name}
npm install .
coffee app.coffee
-----------------
You should nav to http://localhost:3000
-----------------
Thank you for using cupcake, please let us know if you have any problems
"""

  prompt_for_artifacts: (callback) ->
    # init locals
    choices = {}
    i = 0
    keys = Object.keys @ARTIFACTS

    # setup recursion
    prompt = =>
      return callback(choices) if i == keys.length
      key = keys[i]
      val = @ARTIFACTS[key]
      @display_choices val

      @ask 'Enter Number', /[0-9]/, (choice) =>
        option = val.options[parseInt(choice) - 1]
        if option?
          choices[key] = option
          i++
        else
          console.error "Invalid choice"
        prompt()
    prompt()

  run: ->
    unless process.argv.length == 3
      console.log 'Please enter project name!' 
      return

    console.log "Welcome to Cupcake - #{@VERSION}"
    project = {name: process.argv[2]}
    @prompt_for_artifacts (choices) =>
      @project =
        name: process.argv[2]
        framework: 'express' # default
        template: choices.template
        datastore: choices.datastore
      @build_folders()
      @build_files()
      @thank_you()
      process.exit()

exports.cupcake = new Cupcake



