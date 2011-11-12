(function() {
  var App;
  App = {
    start: function() {
      $('select').chosen();
      App.fill();
      App.launchEditors();
      return App.delegate();
    },
    modes: {
      Html: require("ace/mode/html").Mode,
      Sass: require("ace/mode/scss").Mode,
      Js: require("ace/mode/javascript").Mode,
      Coffee: require("ace/mode/coffee").Mode
    },
    launchEditors: function() {
      App.template = ace.edit('templ_editor');
      App.style = ace.edit('style_editor');
      App.script = ace.edit('script_editor');
      App.template.getSession().setMode(new App.modes.Html());
      App.style.getSession().setMode(new App.modes.Sass());
      App.script.getSession().setMode(new App.modes.Coffee());
      return [App.template, App.style, App.script].map(function(e) {
        return e.setTheme('ace/theme/dawn');
      });
    },
    fill: function() {
      $('#templ_editor').text("!!! 5\n%html\n  %head\n  %body\n    %h1 Hey!!");
      $('#style_editor').text("$size: 72px\n\nbody\n  background-color: hsl(350, 80, 60)\n  color: hsl(0, 0, 95)\n\nh1\n  font: $size 'Lucida Grande'\n\nh2\n  font: $size / 2 'Monaco'");
      return $('#script_editor').text("$ -> setTimeout (-> $('body').append '<h2>, it works!!</h2>'), 1200");
    },
    delegate: function() {
      $('.editor .button').click(this.send);
      return $('select').change(this.swapSyntax);
    },
    send: function(e) {
      var src;
      e.preventDefault();
      src = {
        id: $('html').data('_id'),
        templ_lang: $('#select_template select').val(),
        templ_code: App.template.getSession().getValue(),
        style_lang: $('#select_style select').val(),
        style_code: App.style.getSession().getValue(),
        scrpt_lang: $('#select_script select').val(),
        scrpt_code: App.script.getSession().getValue()
      };
      return $.post('/', src, function(res) {
        var r;
        r = JSON.parse(res);
        if ((r.url != null) && r.url.match(App.urlRegex)) {
          App.showLink(r.url);
          App.changeButton();
          return $('html').data('_id', r.id);
        } else {
          return App.showErrors(r);
        }
      });
    },
    changeButton: function() {
      return $('.editor .button').text('Update');
    },
    showLink: function(link) {
      $('#errors p.errs').text("");
      $('#errors h1').fadeOut('fast');
      $('.link a').attr('href', link).text(link);
      return $('.link').css('visibility', 'visible');
    },
    showErrors: function(errors) {
      var e, _results;
      $('#errors h1').fadeIn('fast');
      $('#errors p.errs').text("");
      _results = [];
      for (e in errors) {
        _results.push($('#errors p.errs').append("" + e + ": " + errors[e] + "<br>"));
      }
      return _results;
    },
    swapSyntax: function(e) {
      switch (e.target.value) {
        case 'javascript':
          return App.script.getSession().setMode(new App.modes.Js());
        case 'coffeescript':
          return App.script.getSession().setMode(new App.modes.Coffee());
      }
    },
    urlRegex: /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  };
  $(App.start);
}).call(this);
