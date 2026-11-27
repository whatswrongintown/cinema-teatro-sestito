// Site menu on narrow screens (layouts/partials/nav.html): one "Menu" button
// opens and closes the menu by setting aria-expanded; the CSS shows the menu
// when it is "true". Escape and a click on a menu link close it, and so does
// widening the window past the breakpoint.
(function () {
  var button = document.querySelector('.menu-toggle');
  var menu = document.getElementById('site-menu');
  if (!button || !menu) return;

  function isOpen() { return button.getAttribute('aria-expanded') === 'true'; }
  function setOpen(open) { button.setAttribute('aria-expanded', open ? 'true' : 'false'); }

  button.addEventListener('click', function () { setOpen(!isOpen()); });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && isOpen()) { setOpen(false); button.focus(); }
  });

  menu.addEventListener('click', function (e) {
    if (e.target.closest('a')) setOpen(false);
  });

  var wide = window.matchMedia('(min-width: 900px)');
  var onChange = function (q) { if (q.matches) setOpen(false); };
  if (wide.addEventListener) wide.addEventListener('change', onChange);
  else if (wide.addListener) wide.addListener(onChange);
})();
