Package.describe({
  name: "chroma:autoform-image-file",
  summary: "File upload for AutoForm",
  description: "File upload for AutoForm",
  version: "0.2.8",
  git: "http://github.com/yogiben/autoform-file.git"
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@1.0');

  api.use([
    'coffeescript',
    'underscore',
    'reactive-var',
    'templating',
    'mquandalle:jade',
    'less',
    'aldeed:autoform@5.3.2',
    'fortawesome:fontawesome@4.3.0',
    "benjick:webcam",
    'awatson1978:browser-detection'
  ]);

  api.addFiles('lib/client/autoform-file.jade', 'client');
  api.addFiles('lib/client/autoform-file.less', 'client');
  api.addFiles('lib/client/autoform-file.coffee', 'client');
  api.addFiles('lib/server/publish.coffee', 'server');
});
