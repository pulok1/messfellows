(function () {
  'use strict';

  var root = document.documentElement;
  var toggle = document.getElementById('theme-toggle');
  var iconSun = document.getElementById('icon-sun');
  var iconMoon = document.getElementById('icon-moon');
  var STORAGE_KEY = 'mess-fellows-theme';

  function systemPrefersDark() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }

  function isDark() {
    var stored = localStorage.getItem(STORAGE_KEY);
    if (stored === 'dark') return true;
    if (stored === 'light') return false;
    return systemPrefersDark();
  }

  function applyTheme(dark) {
    root.setAttribute('data-theme', dark ? 'dark' : 'light');
    if (iconSun && iconMoon) {
      iconSun.style.display = dark ? 'none' : 'block';
      iconMoon.style.display = dark ? 'block' : 'none';
    }
    if (toggle) {
      toggle.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
    }
  }

  applyTheme(isDark());

  if (toggle) {
    toggle.addEventListener('click', function () {
      var next = !isDark();
      localStorage.setItem(STORAGE_KEY, next ? 'dark' : 'light');
      applyTheme(next);
    });
  }

  // Follow system theme changes unless the visitor picked one explicitly.
  if (window.matchMedia) {
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function (e) {
      if (!localStorage.getItem(STORAGE_KEY)) applyTheme(e.matches);
    });
  }

  // Reveal-on-scroll for elements marked .reveal.
  var revealEls = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window && revealEls.length) {
    var observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15 }
    );
    revealEls.forEach(function (el) { observer.observe(el); });
  } else {
    revealEls.forEach(function (el) { el.classList.add('is-visible'); });
  }
})();

(function () {
  'use strict';

  var APK_NAME = 'messfellows.apk';
  var RELEASE_API = 'https://api.github.com/repos/pulok1/messfellows/releases/latest';

  // iPhones/iPads can't install an APK: point them at the web app instead.
  var ua = navigator.userAgent || '';
  var isIOS = /iPad|iPhone|iPod/.test(ua) || (ua.indexOf('Mac') !== -1 && navigator.maxTouchPoints > 1);
  var iosHint = document.querySelector('.ios-hint');
  if (isIOS && iosHint) iosHint.hidden = false;

  // Show the current version and size next to the download buttons (silently skipped on failure).
  var metaEls = document.querySelectorAll('[data-apk-meta]');
  if (metaEls.length && window.fetch) {
    fetch(RELEASE_API, { headers: { Accept: 'application/vnd.github+json' } })
      .then(function (r) { return r.ok ? r.json() : Promise.reject(); })
      .then(function (release) {
        var asset = (release.assets || []).filter(function (a) { return a.name === APK_NAME; })[0];
        var version = /^v(\d+\.\d+\.\d+)/.exec(release.tag_name || '');
        if (!asset || !version) return;
        var mb = Math.round(asset.size / 1048576);
        var text = 'Version ' + version[1] + ' \u00b7 ' + mb + ' MB \u00b7 Free, no account needed';
        metaEls.forEach(function (el) { el.textContent = text; });
      })
      .catch(function () {});
  }

  // Sticky download bar on phones: visible only while neither the hero buttons nor the
  // download section are on screen.
  var bar = document.getElementById('sticky-cta');
  var heroActions = document.querySelector('.hero-actions');
  var downloadSection = document.getElementById('download');
  if (bar && heroActions && downloadSection && 'IntersectionObserver' in window && !isIOS) {
    var visible = { hero: true, download: false };
    var update = function () { bar.classList.toggle('is-visible', !visible.hero && !visible.download); };
    var watch = function (el, key) {
      new IntersectionObserver(function (entries) {
        visible[key] = entries[0].isIntersecting;
        update();
      }).observe(el);
    };
    watch(heroActions, 'hero');
    watch(downloadSection, 'download');
  }
})();
