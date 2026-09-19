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
