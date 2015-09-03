AutoForm.addInputType 'imageFileUpload',
  template: 'afImageFileUpload'
  valueOut: ->
    @val()

getCollection = (context) ->
  if typeof context.atts.collection == 'string'
    FS._collections[context.atts.collection] or window[context.atts.collection]

getDocument = (context) ->
  collection = getCollection context
  id = Template.instance()?.value?.get?()
  collection?.findOne(id)

Template.afImageFileUpload.onCreated ->
  self = @
  @value = new ReactiveVar @data.value

  @autorun ->
    _id = self.value.get()
    _id and Meteor.subscribe 'autoformImageFileDoc', self.data.atts.collection, _id

Template.afImageFileUpload.onRendered ->
  self = @
  $(self.firstNode).closest('form').on 'reset', ->
    self.value.set null
  Webcam.on 'error', (err) ->
    console.log err
    # outputs error to console instead of window.alert
    return
  Webcam.setSWFLocation("/packages/benjick_webcam/webcamjs/webcam.swf")
  Webcam.set
    width: 320
    height: 240
    dest_width: 640
    dest_height: 480
    image_format: 'jpeg'
    jpeg_quality: 90
  Webcam.attach '.webcam'

Template.imageProgressBar.helpers
  progress: ->
    return parseInt(Session.get('uploaderProgress') || 0)

Template.afImageFileUpload.helpers
  compatibleBrowser: ->
    if BrowserDetect.browser == 'Safari' && BrowserDetect.OS == 'Mac'
      return false
    else if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
      return false
    else
      return true
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
      'afImageFileUploadThumbImg'
    else
      'afImageFileUploadThumbIcon'
  file: ->
    getDocument @

setValue = (val, e, t) ->
  t.value.set(val)
  t.data.value = val
  $form = $(t.firstNode).closest('form')[0]
  $(t.find('.js-value')).keyup()
  AutoForm.validateField($form.id, t.data.name, false)

Template.afImageFileUpload.events
  'click .js-select-file': (e, t) ->
    t.$('.js-file').click()

  'click .js-camera-file': (e, t) ->
    Webcam.snap (image) ->

      file = new FS.File image
      if Meteor.userId
        file.createdBy = Meteor.userId()

      collection = getCollection t.data

      Session.set('uploaderProgress', 0)

      collection.insert file, (err, fileObj) ->
        if err then return console.log err
        setValue(fileObj._id , e ,t);
        progress = setInterval(->
          pct = fileObj.uploadProgress()
          if (pct >= 100)
            clearInterval(progress)
          Session.set('uploaderProgress', pct)
        , 250)

  'click .js-remove': (e, t) ->
    e.preventDefault()
    setValue(undefined, e,t);

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
        Session.set('uploaderProgress', pct)
      , 250)

Template.afImageFileUploadThumbIcon.helpers
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
