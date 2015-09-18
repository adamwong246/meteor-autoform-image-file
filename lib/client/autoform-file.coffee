AutoForm.addInputType 'fileUpload',
  template: 'afFileUpload'
  valueOut: ->
    @val()

getCollection = (context) ->
  if typeof context.atts.collection == 'string'
    FS._collections[context.atts.collection] or window[context.atts.collection]

getDocument = (context) ->
  collection = getCollection context
  id = Template.instance()?.value?.get?()
  collection?.findOne(id)

Template.afFileUpload.onCreated ->
  self = @
  @value = new ReactiveVar @data.value

  @autorun ->
    _id = self.value.get()
    _id and Meteor.subscribe 'autoformFileDoc', self.data.atts.collection, _id

Template.afFileUpload.onRendered ->
  self = @
  $(self.firstNode).closest('form').on 'reset', ->
    self.value.set null

Template.progressBar.helpers
  progress: ->
    return parseInt(Session.get('uploaderProgress') || 0)

Template.afFileUpload.helpers
  label: ->
    @atts.label or 'Choose file'
  removeLabel: ->
    @atts.removeLabel or 'Remove'
  value: ->
    doc = getDocument @
    doc?.isUploaded() and doc._id
  schemaKey: ->
    @atts['data-schema-key']
  previewTemplate: ->
    doc = getDocument @
    if doc?.isImage()
      'afFileUploadThumbImg'
    else
      'afFileUploadThumbIcon'
  file: ->
    getDocument @

setValue = (val, e, t) ->
  t.value.set(val)
  t.data.value = val
  update(t)

update = (t) ->
  $(t.find('.js-value')).keyup()
  $(t.find('.js-value')).trigger('change')

Template.afFileUpload.events
  'click .js-select-file': (e, t) ->
    e.preventDefault()
    t.$('.js-file').click()
    return false

  'click .js-remove': (e, t) ->
    e.preventDefault()
    setValue(undefined, e,t)
    return false

  'change .js-file': (e, t) ->
    file = new FS.File e.target.files[0]
    if Meteor.userId
      file.createdBy = Meteor.userId()

    collection = getCollection t.data
    #console.log([name, 'change .js-file', e.target, t, file, collection]);

    Session.set('uploaderProgress', 0)

    collection.insert file, (err, fileObj) ->
      if err then return console.log err
      setValue(fileObj._id , e ,t);
      progress = setInterval(->
        pct = fileObj.uploadProgress()
        if (pct >= 100)
          clearInterval(progress)
          update(t)
        Session.set('uploaderProgress', pct)
      , 250)

Template.afFileUploadThumbIcon.helpers
  icon: ->
    switch @extension()
      when 'pdf'
        'file-pdf-o'
      when 'doc', 'docx'
        'file-word-o'
      when 'ppt', 'avi', 'mov', 'mp4'
        'file-powerpoint-o'
      else
        'file-o'
