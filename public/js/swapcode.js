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
      $('#templ_editor').text("!!! 5\n%html\n  %head\n  %body\n    %h1 Hey!");
      $('#style_editor').text("$size: 72px\n\nbody\n  background-color: hsl(350, 80, 60)\n  color: hsl(0, 0, 95)\n\nh1\n  font: $size 'Comic Sans MS'\n\nh2\n  font: $size / 2 'Monaco'");
      return $('#script_editor').text("$ -> setTimeout (-> $('body').append '<h2>It works!</h2>'), 1200");
    },
    delegate: function() {
      $('.editor .button').click(this.send);
      $('select').change(this.swapSyntax);
      $('#open a').click(this.openUrl);
      return $('#open input').keydown(function(e) {
        if (e.which === 13) {
          return App.openUrl(e);
        }
      });
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
      return $.post('/page/create', src, function(res) {
        var r;
        r = JSON.parse(res);
        if ((r.url != null) && r.url.match(App.urlRegex)) {
          App.showLink(r.url);
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
      link = "" + window.location.origin + "/views/" + link;
      $('#errors p.errs').text("");
      $('#errors h1').fadeOut('fast');
      $('.link a').attr('href', link).text(link);
      $('.link').css('visibility', 'visible');
      return App.changeButton();
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
    openUrl: function(e) {
      var url;
      e.preventDefault();
      url = $('#open input').val();
      if (!url.match(App.urlRegex)) {
        return null;
      }
      return $.get('/page/open', {
        url: url
      }, function(res) {
        var p, r;
        r = JSON.parse(res);
        if (r.page != null) {
          p = r.page;
          return App.openPage(p);
        } else {
          return console.log(r);
        }
      });
    },
    openPage: function(p) {
      $('html').data('_id', p.id);
      $('#select_template select').val(p.templ_lang);
      App.template.getSession().setValue(p.templ_code);
      $('#select_style select').val(p.style_lang);
      App.style.getSession().setValue(p.style_code);
      $('#select_script select').val(p.script_lang);
      App.script.getSession().setValue(p.script_code);
      return App.showLink(p.url);
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
