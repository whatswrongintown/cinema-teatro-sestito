// Home "In questi giorni": redoes for the visitor's date the selection Hugo
// rendered for the build date (layouts/partials/home/cartellone.html; keep
// the rules in step). Screenings come from /cartellone/MM.json, arrays of
// [date, title, genres, source, film URL, thumb, large, format].
(function () {
  'use strict';
  var root = document.querySelector('[data-cartellone]');
  if (!root || !window.fetch || !window.Intl) return;

  var mesi = JSON.parse(root.getAttribute('data-mesi') || '{}');
  var anni = JSON.parse(root.getAttribute('data-anni') || '{}');
  var pad = function (n) { return (n < 10 ? '0' : '') + n; };
  var oggi = new Date();
  var giorni = [];
  var mesiDaLeggere = [];
  for (var i = -3; i <= 3; i++) {
    var d = new Date(oggi.getFullYear(), oggi.getMonth(), oggi.getDate() + i);
    var mese = pad(d.getMonth() + 1);
    giorni.push(mese + '-' + pad(d.getDate()));
    if (mesiDaLeggere.indexOf(mese) < 0) mesiDaLeggere.push(mese);
  }
  // Same window as the build: nothing to do.
  if (giorni.join(',') === root.getAttribute('data-giorni')) return;

  var fmt = function (opts) { return new Intl.DateTimeFormat('it-IT', opts); };
  var giornoMese = fmt({ day: 'numeric', month: 'long' });

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function data(s) {
    var p = s.split('-');
    return new Date(+p[0], +p[1] - 1, +p[2]);
  }

  function scegli(righe) {
    var perAnno = {};
    var ordine = [];
    righe.forEach(function (r) {
      if (giorni.indexOf(r[0].slice(5)) < 0) return;
      var anno = r[0].slice(0, 4);
      var prima = perAnno[anno];
      if (!prima) { perAnno[anno] = r; ordine.push(anno); }
      else if (!prima[5] && r[5]) perAnno[anno] = r;
    });
    ordine.sort();
    var candidati = ordine.map(function (a) { return perAnno[a]; });
    var n = candidati.length;
    if (n <= 6) return candidati;
    var scelte = [];
    for (var k = 0; k <= 5; k++) scelte.push(candidati[Math.floor(k * (n - 1) / 5)]);
    return scelte;
  }

  function riga(r, inEvidenza) {
    var d = data(r[0]);
    var li = el('li', 'show' + (inEvidenza ? ' show-featured' : ''));
    var time = el('time', 'show-date');
    time.setAttribute('datetime', r[0]);
    time.appendChild(el('span', 'label show-dow', fmt({ weekday: 'short' }).format(d).replace('.', '')));
    time.appendChild(el('span', 'show-day', String(d.getDate())));
    time.appendChild(el('span', 'label show-month', fmt({ month: 'short' }).format(d).replace('.', '') + ' ' + d.getFullYear()));
    li.appendChild(time);

    var body = el('div', 'show-body');
    var h3 = el('h3', 'show-title');
    var link = r[4] || anni[r[0].slice(0, 4)];
    if (link) {
      var a = el('a', null, r[1]);
      a.href = link;
      h3.appendChild(a);
    } else {
      h3.textContent = r[1];
    }
    body.appendChild(h3);
    if (r[2]) body.appendChild(el('p', 'label show-meta', r[2]));
    if (r[3]) body.appendChild(el('p', 'label show-source', 'Fonte: ' + r[3]));
    li.appendChild(body);
    return li;
  }

  function evidenza(aside, r) {
    aside.textContent = '';
    if (!r) { aside.hidden = true; return; }
    var a = el('a');
    a.href = r[4];
    var img = el('img');
    img.src = r[5];
    img.alt = r[1] + ', ' + r[7].toLowerCase();
    // Width and height from the format (e.g. "manifesto 70x100") reserve the
    // space, as the build-time markup does.
    var dim = /(\d+)x(\d+)/.exec(r[7]);
    if (dim) { img.width = +dim[1]; img.height = +dim[2]; }
    img.loading = 'lazy';
    img.decoding = 'async';
    a.appendChild(img);
    aside.appendChild(a);
    aside.appendChild(el('p', 'label show-poster-format', r[7]));
    aside.appendChild(el('p', 'show-poster-title', r[1]));
    var quando = fmt({ weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }).format(data(r[0]));
    aside.appendChild(el('p', 'show-poster-note', 'In sala ' + quando + '.'));
    aside.hidden = false;
  }

  Promise.all(mesiDaLeggere.map(function (m) {
    return mesi[m] ? fetch(mesi[m]).then(function (res) { return res.ok ? res.json() : []; }) : Promise.resolve([]);
  })).then(function (liste) {
    var righe = [].concat.apply([], liste);
    var scelte = scegli(righe);
    var primo = null;
    scelte.forEach(function (r) { if (!primo && r[5]) primo = r; });

    var lista = root.querySelector('[data-cartellone-lista]');
    lista.textContent = '';
    if (!scelte.length) {
      lista.appendChild(el('li', 'show-empty', 'Nessun film in cartellone in questi giorni.'));
    }
    scelte.forEach(function (r) { lista.appendChild(riga(r, r === primo)); });
    evidenza(root.querySelector('[data-cartellone-evidenza]'), primo);

    var dal = new Date(oggi.getFullYear(), oggi.getMonth(), oggi.getDate() - 3);
    var al = new Date(oggi.getFullYear(), oggi.getMonth(), oggi.getDate() + 3);
    var periodo = dal.getMonth() === al.getMonth()
      ? 'dal ' + dal.getDate() + ' al ' + giornoMese.format(al)
      : 'dal ' + giornoMese.format(dal) + ' al ' + giornoMese.format(al);
    root.querySelector('[data-cartellone-periodo]').textContent =
      'I film in cartellone ' + periodo + ', anno dopo anno.';
  }).catch(function () { /* Keep the build-time selection. */ });
})();
