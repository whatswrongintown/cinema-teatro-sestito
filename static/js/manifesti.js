// Posters landing page: "Manifesto del giorno" for the visitor's date and the
// "Un manifesto a caso" button. Data: /posters/indice.json, arrays of
// [title, film page, large, thumb, format, production year, first screening]
// built by layouts/partials/posters/indice.html, which renders the poster of
// the build date with the same rule (day number modulo the list length).
(function () {
  'use strict';
  var root = document.querySelector('[data-manifesti]');
  if (!root || !window.fetch) return;

  var dati = null;
  function carica() {
    if (!dati) {
      dati = fetch(root.getAttribute('data-indice'))
        .then(function (res) { return res.ok ? res.json() : []; });
    }
    return dati;
  }

  var caso = root.querySelector('[data-manifesto-caso]');
  if (caso) {
    caso.hidden = false;
    caso.addEventListener('click', function () {
      carica().then(function (lista) {
        if (!lista.length) return;
        var r = lista[Math.floor(Math.random() * lista.length)];
        if (r[1]) window.location.href = r[1];
      });
    });
  }

  var oggi = new Date();
  var giorno = Math.floor(Date.UTC(oggi.getFullYear(), oggi.getMonth(), oggi.getDate()) / 86400000);
  var figura = root.querySelector('[data-manifesto-giorno]');
  if (!figura || String(giorno) === root.getAttribute('data-giorno')) return;

  carica().then(function (lista) {
    if (!lista.length) return;
    var r = lista[giorno % lista.length];
    var link = figura.querySelector('.poster-day-link');
    var img = link.querySelector('img');
    link.href = r[1];
    img.removeAttribute('width');
    img.removeAttribute('height');
    img.src = r[2];
    img.alt = r[0] + ', ' + r[4].toLowerCase();
    figura.querySelector('.poster-day-title').textContent = r[0];
    figura.querySelector('.poster-day-meta').textContent = (r[5] ? r[5] + ' · ' : '') + r[4];
    var nota = figura.querySelector('.poster-day-note');
    if (r[6]) {
      var p = r[6].split('-');
      var data = new Intl.DateTimeFormat('it-IT', { day: 'numeric', month: 'long', year: 'numeric' })
        .format(new Date(+p[0], +p[1] - 1, +p[2]));
      if (!nota) {
        nota = document.createElement('span');
        nota.className = 'poster-day-note';
        figura.querySelector('figcaption').appendChild(nota);
      }
      nota.textContent = 'In sala ' + data;
    } else if (nota) {
      nota.remove();
    }
  }).catch(function () { /* Keep the build-time poster. */ });
})();
