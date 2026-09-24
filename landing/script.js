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

  var DOWNLOAD_BASE = 'https://github.com/pulok1/messfellows/releases/latest/download/';
  var APK_64 = 'messfellows.apk';
  var APK_32 = 'messfellows-32bit.apk';
  var RELEASE_API = 'https://api.github.com/repos/pulok1/messfellows/releases/latest';

  var ua = navigator.userAgent || '';
  var isIOS = /iPad|iPhone|iPod/.test(ua) || (ua.indexOf('Mac') !== -1 && navigator.maxTouchPoints > 1);
  var apkLinks = document.querySelectorAll('[data-apk]');
  var olderNote = document.querySelector('.cta-older');
  var apkName = APK_64;

  // iPhones/iPads can't install an APK: hide the Android buttons and make the web app the
  // main action instead.
  if (isIOS) {
    var iosHint = document.querySelector('.ios-hint');
    if (iosHint) iosHint.hidden = false;
    apkLinks.forEach(function (a) { a.hidden = true; });
    if (olderNote) olderNote.hidden = true;
    document.querySelectorAll('[data-web-app]').forEach(function (a) {
      a.classList.replace('btn-ghost', 'btn-primary');
      a.classList.replace('btn-outline-light', 'btn-light');
    });
  }

  // A 32-bit Android browser means the phone runs 32-bit apps, so the 32-bit APK is guaranteed
  // to install there; the arm64-only one may not. (Chrome reports "armv8l" when running 32-bit
  // on a 64-bit CPU; the frozen "armv81" value is deliberately not matched.)
  function applyApk(name) {
    apkName = name;
    apkLinks.forEach(function (a) { a.href = DOWNLOAD_BASE + name; });
    if (olderNote && name === APK_32) {
      olderNote.innerHTML = 'We picked the 32-bit version for your phone. Newer phone? ' +
        '<a href="' + DOWNLOAD_BASE + APK_64 + '" download>Download the standard version</a>.';
    }
  }
  var is32BitAndroid = /Android/i.test(ua) && /armv7|armv8l\b|i686/i.test(navigator.platform || '');
  if (is32BitAndroid) applyApk(APK_32);
  var archCheck = Promise.resolve();
  if (/Android/i.test(ua) && !is32BitAndroid && navigator.userAgentData && navigator.userAgentData.getHighEntropyValues) {
    archCheck = navigator.userAgentData.getHighEntropyValues(['bitness'])
      .then(function (v) { if (v.bitness === '32') applyApk(APK_32); })
      .catch(function () {});
  }

  // Show the current version and size next to the download buttons (silently skipped on failure).
  var metaEls = document.querySelectorAll('[data-apk-meta]');
  if (isIOS) metaEls.forEach(function (el) { el.hidden = true; });
  if (metaEls.length && window.fetch && !isIOS) {
    Promise.all([fetch(RELEASE_API, { headers: { Accept: 'application/vnd.github+json' } }), archCheck])
      .then(function (res) { return res[0].ok ? res[0].json() : Promise.reject(); })
      .then(function (release) {
        var asset = (release.assets || []).filter(function (a) { return a.name === apkName; })[0];
        var version = /^v(\d+\.\d+\.\d+)/.exec(release.tag_name || '');
        if (!asset || !version) return;
        var mb = Math.round(asset.size / 1048576);
        var text = 'Version ' + version[1] + ' \u00b7 ' + mb + ' MB' +
          (apkName === APK_32 ? ' (32-bit)' : '') + ' \u00b7 Free, no account needed';
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
