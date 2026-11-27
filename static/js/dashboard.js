/* Historical programming dashboard: filters, tables and SVG charts, no dependencies.
   Data: JSON built by Hugo (layouts/partials/programmazione/dashboard-dati.html). */
(function () {
  'use strict';
  var root = document.querySelector('.dashboard');
  if (!root) return;
  var NS = 'http://www.w3.org/2000/svg';
  var MONTHS = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
  var N_A = 'Non disponibile';
  var collator = new Intl.Collator('it');

  function $(id) { return document.getElementById(id); }
  function fmt(n) { return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, '.'); }
  function dec(n) { return String(n).replace('.', ','); }
  function el(tag, attrs, text) {
    var e = document.createElement(tag);
    for (var k in attrs || {}) e.setAttribute(k, attrs[k]);
    if (text != null) e.textContent = text;
    return e;
  }
  function svgEl(tag, attrs, text) {
    var e = document.createElementNS(NS, tag);
    for (var k in attrs || {}) e.setAttribute(k, attrs[k]);
    if (text != null) e.textContent = text;
    return e;
  }
  function list(values) { return values.length ? values.join(', ') : N_A; }

  function fetchText(url) {
    return fetch(url).then(function (r) { if (!r.ok) throw new Error(r.status); return r.text(); });
  }
  Promise.all([fetchText(root.getAttribute('data-agende')), fetchText(root.getAttribute('data-imdb'))])
    .then(function (texts) { start(prepare(parseCsv(texts[0]), parseCsv(texts[1]))); })
    .catch(function () {
      var s = root.querySelector('.dashboard-status');
      s.textContent = 'Non è stato possibile caricare i dati. Riprova più tardi.';
    });

  /* ---------- data ---------- */
  /* Minimal CSV parser (quoted cells, doubled quotes, CR/LF) -> array of objects by header. */
  function parseCsv(text) {
    if (text.charCodeAt(0) === 0xFEFF) text = text.slice(1);
    var rows = [], row = [], cell = '', quoted = false, i = 0, c;
    for (; i < text.length; i++) {
      c = text[i];
      if (quoted) {
        if (c === '"') { if (text[i + 1] === '"') { cell += '"'; i++; } else quoted = false; }
        else cell += c;
      } else if (c === '"') quoted = true;
      else if (c === ',') { row.push(cell); cell = ''; }
      else if (c === '\n' || c === '\r') {
        if (c === '\r' && text[i + 1] === '\n') i++;
        row.push(cell); cell = ''; rows.push(row); row = [];
      } else cell += c;
    }
    if (cell || row.length) { row.push(cell); rows.push(row); }
    var head = rows.shift().map(function (h) { return h.trim(); });
    return rows.filter(function (r) { return r.length > 1 || r[0] !== ''; }).map(function (r) {
      var o = {}; head.forEach(function (h, k) { o[h] = (r[k] || '').trim(); }); return o;
    });
  }
  function splitList(value) {
    var out = [];
    value.split(',').forEach(function (v) { v = v.trim(); if (v && out.indexOf(v) < 0) out.push(v); });
    return out;
  }
  /* Entries come from the screening CSV; films without an IMDb row (a few adult
     films) or without an ID get a bare record keyed by ID or, failing that, title. */
  function prepare(agende, imdb) {
    var byId = {}, films = {};
    imdb.forEach(function (r) {
      if (!/^tt[0-9]+$/.test(r.Const) || byId[r.Const]) throw new Error('IMDb ID: ' + r.Const);
      var rating = parseFloat(r['IMDb Rating']), votes = parseInt(r['Num Votes'], 10);
      byId[r.Const] = { id: r.Const, title: r.Title, rating: isNaN(rating) ? null : rating,
        votes: isNaN(votes) ? null : votes, directors: splitList(r.Directors), genres: splitList(r.Genres) };
    });
    var n = 0, entries = agende.map(function (r) {
      if (!/^\d{4}-\d{2}-\d{2}$/.test(r.date)) throw new Error('date: ' + r.date);
      var key = r.const || 'titolo:' + r.title.toLowerCase(), film = films[key];
      if (!film) {
        film = films[key] = byId[r.const] || { id: r.const, title: '', rating: null, votes: null, directors: [], genres: [] };
        film.idx = n++;
      }
      return { date: r.date, year: +r.date.slice(0, 4), month: +r.date.slice(5, 7), film: film,
               recorded: r.title, title: film.title || r.title, sources: splitList(r.source) };
    });
    entries.sort(function (a, b) {
      return a.date < b.date ? -1 : a.date > b.date ? 1 : a.film.id < b.film.id ? -1 : a.film.id > b.film.id ? 1 : 0;
    });
    return entries;
  }
  function uniqueFilms(entries) {
    var seen = {}, out = [];
    entries.forEach(function (e) { if (!seen[e.film.idx]) { seen[e.film.idx] = 1; out.push(e); } });
    return out;
  }
  function counts(values) {
    var map = {};
    values.forEach(function (v) { map[v] = (map[v] || 0) + 1; });
    return Object.keys(map).map(function (k) { return [k, map[k]]; }).sort(function (a, b) {
      return b[1] - a[1] || collator.compare(a[0], b[0]);
    });
  }
  function ratedFilms(films) {
    return films.filter(function (e) { return e.film.rating != null && e.film.votes != null && e.film.votes > 0; });
  }
  function ranking(films, descending) {
    return ratedFilms(films).sort(function (a, b) {
      var d = descending ? b.film.rating - a.film.rating : a.film.rating - b.film.rating;
      return d || b.film.votes - a.film.votes || (a.film.id < b.film.id ? -1 : 1);
    }).slice(0, 5);
  }
  function imdbLink(title, id) {
    if (!/^tt[0-9]+$/.test(id)) return document.createTextNode(title);
    return el('a', { href: 'https://www.imdb.com/title/' + id + '/', target: '_blank', rel: 'noopener noreferrer' }, title);
  }

  /* ---------- tables ---------- */
  /* cols: [{label, text(row), node(row)?, key(row)?}]; returns {update(rows)} */
  function pagedTable(host, cols, o) {
    o = o || {};
    var size = o.pageSize || 10, state = { rows: [], page: 0, sort: null, dir: 1, q: '' };
    var search = null;
    if (o.search) {
      var wrap = el('p', { 'class': 'dashboard-search' });
      var id = host.id + '-q';
      wrap.appendChild(el('label', { 'for': id }, 'Cerca:'));
      search = el('input', { type: 'search', id: id });
      search.addEventListener('input', function () { state.q = search.value.toLowerCase(); state.page = 0; render(); });
      wrap.appendChild(search);
      host.appendChild(wrap);
    }
    var scroll = el('div', { 'class': 'dashboard-table-wrap' });
    var info = el('p', { 'class': 'dashboard-note', role: 'status' });
    var pager = el('div', { 'class': 'dashboard-pager' });
    host.appendChild(scroll); host.appendChild(info); host.appendChild(pager);

    function visible() {
      var rows = state.rows;
      if (state.q) {
        rows = rows.filter(function (r) {
          return cols.some(function (c) { return String(c.text(r)).toLowerCase().indexOf(state.q) !== -1; });
        });
      }
      if (state.sort != null) {
        var c = cols[state.sort], k = c.key || c.text, d = state.dir;
        rows = rows.slice().sort(function (a, b) {
          var x = k(a), y = k(b);
          if (typeof x === 'number' && typeof y === 'number') return (x - y) * d;
          return collator.compare(String(x), String(y)) * d;
        });
      }
      return rows;
    }
    function render() {
      var rows = visible(), pages = Math.max(1, Math.ceil(rows.length / size));
      if (state.page >= pages) state.page = pages - 1;
      var table = el('table'), head = el('tr');
      cols.forEach(function (c, i) {
        var th = el('th', { scope: 'col' });
        th.setAttribute('aria-sort', state.sort === i ? (state.dir > 0 ? 'ascending' : 'descending') : 'none');
        if (o.sortable === false) th.textContent = c.label;
        else {
          var b = el('button', { type: 'button' }, c.label);
          b.addEventListener('click', function () {
            if (state.sort === i) state.dir = -state.dir; else { state.sort = i; state.dir = 1; }
            state.page = 0; render();
            var again = scroll.querySelectorAll('th button')[i]; if (again) again.focus();
          });
          th.appendChild(b);
        }
        head.appendChild(th);
      });
      var thead = el('thead'); thead.appendChild(head); table.appendChild(thead);
      var tbody = el('tbody');
      rows.slice(state.page * size, state.page * size + size).forEach(function (r) {
        var tr = el('tr');
        cols.forEach(function (c) {
          var td = el('td');
          if (c.node) td.appendChild(c.node(r)); else td.textContent = c.text(r);
          tr.appendChild(td);
        });
        tbody.appendChild(tr);
      });
      table.appendChild(tbody);
      if (!rows.length) {
        var tr = el('tr'), td = el('td', { colspan: cols.length }, 'Nessun risultato');
        tr.appendChild(td); tbody.appendChild(tr);
      }
      scroll.replaceChildren(table);
      var from = rows.length ? state.page * size + 1 : 0, to = Math.min(rows.length, (state.page + 1) * size);
      info.textContent = rows.length ? 'Da ' + fmt(from) + ' a ' + fmt(to) + ' di ' + fmt(rows.length) + ' righe' : 'Nessuna riga';
      pager.replaceChildren();
      if (pages > 1) {
        var prev = el('button', { type: 'button' }, 'Precedente'), next = el('button', { type: 'button' }, 'Successiva');
        prev.disabled = state.page === 0; next.disabled = state.page >= pages - 1;
        prev.addEventListener('click', function () { state.page--; render(); });
        next.addEventListener('click', function () { state.page++; render(); });
        pager.appendChild(prev);
        pager.appendChild(el('span', null, 'Pagina ' + (state.page + 1) + ' di ' + pages));
        pager.appendChild(next);
      }
    }
    return { update: function (rows) { state.rows = rows; state.page = 0; render(); } };
  }

  function simpleTable(host, heads, rows) {
    var table = el('table'), tr = el('tr');
    heads.forEach(function (h) { tr.appendChild(el('th', { scope: 'col' }, h)); });
    var thead = el('thead'); thead.appendChild(tr); table.appendChild(thead);
    var tbody = el('tbody');
    rows.forEach(function (r) {
      var row = el('tr');
      r.forEach(function (cell) {
        var td = el('td');
        if (cell instanceof Node) td.appendChild(cell); else td.textContent = cell;
        row.appendChild(td);
      });
      tbody.appendChild(row);
    });
    if (!rows.length) tbody.appendChild(el('tr')).appendChild(el('td', { colspan: heads.length }, 'Nessun dato disponibile'));
    table.appendChild(tbody);
    var wrap = el('div', { 'class': 'dashboard-table-wrap' }); wrap.appendChild(table);
    host.replaceChildren(wrap);
  }

  /* ---------- charts ---------- */
  function emptyChart(message) {
    var svg = svgEl('svg', { viewBox: '0 0 640 120', role: 'img', 'aria-label': message });
    svg.appendChild(svgEl('text', { x: 320, y: 60, 'text-anchor': 'middle' }, message));
    return svg;
  }
  function monthChart(entries) {
    if (!entries.length) return emptyChart('Nessun film in cartellone');
    var data = monthCounts(entries), max = Math.max.apply(null, data), top = max * 1.15;
    var W = 640, H = 360, L = 50, R = 12, T = 40, B = 40, pw = W - L - R, ph = H - T - B;
    var svg = svgEl('svg', { viewBox: '0 0 ' + W + ' ' + H, role: 'img',
      'aria-label': 'Film per mese: totale ' + entries.length });
    svg.appendChild(svgEl('text', { x: W / 2, y: 22, 'text-anchor': 'middle', 'class': 'title' }, 'Totale: ' + fmt(entries.length) + ' film'));
    niceTicks(0, top, 5).forEach(function (t) {
      var y = T + ph - t / top * ph;
      svg.appendChild(svgEl('line', { x1: L, x2: W - R, y1: y, y2: y, 'class': 'grid' }));
      svg.appendChild(svgEl('text', { x: L - 6, y: y + 4, 'text-anchor': 'end' }, fmt(t)));
    });
    var slot = pw / 12;
    data.forEach(function (n, i) {
      var h = n / top * ph, x = L + i * slot + slot * 0.1;
      var bar = svgEl('rect', { x: x, y: T + ph - h, width: slot * 0.8, height: h, 'class': 'bar' });
      bar.appendChild(svgEl('title', null, MONTHS[i] + ': ' + n));
      svg.appendChild(bar);
      svg.appendChild(svgEl('text', { x: x + slot * 0.4, y: T + ph - h - 4, 'text-anchor': 'middle' }, n));
      svg.appendChild(svgEl('text', { x: x + slot * 0.4, y: H - B + 16, 'text-anchor': 'middle' }, MONTHS[i]));
    });
    svg.appendChild(svgEl('line', { x1: L, x2: W - R, y1: T + ph, y2: T + ph, 'class': 'axis' }));
    svg.appendChild(svgEl('text', { x: 14, y: T + ph / 2, 'text-anchor': 'middle', transform: 'rotate(-90 14 ' + (T + ph / 2) + ')' }, 'Film'));
    return svg;
  }
  function genreChart(films) {
    var data = genreCounts(films);
    if (!data.length) return emptyChart('Generi non disponibili');
    var rowH = 24, L = 130, R = 40, T = 10, B = 40, W = 640, H = T + B + rowH * data.length;
    var max = data[0][1], pw = W - L - R;
    var svg = svgEl('svg', { viewBox: '0 0 ' + W + ' ' + H, role: 'img', 'aria-label': 'Film distinti per genere' });
    data.forEach(function (d, i) {
      var y = T + i * rowH, w = d[1] / max * pw;
      svg.appendChild(svgEl('text', { x: L - 6, y: y + rowH / 2 + 4, 'text-anchor': 'end' }, d[0]));
      var bar = svgEl('rect', { x: L, y: y + 3, width: w, height: rowH - 6, 'class': 'bar' });
      bar.appendChild(svgEl('title', null, d[0] + ': ' + d[1]));
      svg.appendChild(bar);
      svg.appendChild(svgEl('text', { x: L + w + 4, y: y + rowH / 2 + 4 }, d[1]));
    });
    svg.appendChild(svgEl('line', { x1: L, x2: L, y1: T, y2: H - B, 'class': 'axis' }));
    svg.appendChild(svgEl('text', { x: L + pw / 2, y: H - 12, 'text-anchor': 'middle' }, 'Film distinti'));
    return svg;
  }
  function imdbChart(films) {
    var rated = ratedFilms(films);
    if (!rated.length) return emptyChart('Dati IMDb non disponibili');
    var W = 640, H = 420, L = 50, R = 14, T = 14, B = 56, pw = W - L - R, ph = H - T - B;
    var lo = Infinity, hi = 0;
    rated.forEach(function (e) { lo = Math.min(lo, e.film.votes); hi = Math.max(hi, e.film.votes); });
    var a = Math.log10(lo), b = Math.log10(hi);
    if (a === b) { a -= 0.5; b += 0.5; } else { var pad = (b - a) * 0.04; a -= pad; b += pad; }
    function X(v) { return L + (Math.log10(v) - a) / (b - a) * pw; }
    function Y(r) { return T + ph - r / 10 * ph; }
    var svg = svgEl('svg', { viewBox: '0 0 ' + W + ' ' + H, role: 'img',
      'aria-label': 'Valutazione IMDb in relazione al numero di voti, ' + rated.length + ' titoli' });
    [0, 2, 4, 6, 8, 10].forEach(function (r) {
      svg.appendChild(svgEl('line', { x1: L, x2: W - R, y1: Y(r), y2: Y(r), 'class': 'grid' }));
      svg.appendChild(svgEl('text', { x: L - 6, y: Y(r) + 4, 'text-anchor': 'end' }, r));
    });
    for (var p = Math.ceil(a); p <= Math.floor(b); p++) {
      var x = X(Math.pow(10, p));
      svg.appendChild(svgEl('line', { x1: x, x2: x, y1: T, y2: T + ph, 'class': 'grid' }));
      svg.appendChild(svgEl('text', { x: x, y: T + ph + 16, 'text-anchor': 'middle' }, fmt(Math.pow(10, p))));
    }
    svg.appendChild(svgEl('line', { x1: L, x2: W - R, y1: T + ph, y2: T + ph, 'class': 'axis' }));
    svg.appendChild(svgEl('line', { x1: L, x2: L, y1: T, y2: T + ph, 'class': 'axis' }));
    rated.forEach(function (e) {
      var c = svgEl('circle', { cx: X(e.film.votes).toFixed(1), cy: Y(e.film.rating).toFixed(1), r: 3.6, 'class': 'dot' });
      c.appendChild(svgEl('title', null, e.recorded + ' – IMDb ' + dec(e.film.rating) + ', ' + fmt(e.film.votes) + ' voti'));
      svg.appendChild(c);
    });
    svg.appendChild(svgEl('text', { x: L + pw / 2, y: H - 22, 'text-anchor': 'middle' }, 'Numero di voti (scala logaritmica)'));
    svg.appendChild(svgEl('text', { x: 12, y: T + ph / 2, 'text-anchor': 'middle', transform: 'rotate(-90 12 ' + (T + ph / 2) + ')' }, 'Valutazione media IMDb'));
    svg.appendChild(svgEl('text', { x: W - R, y: H - 4, 'text-anchor': 'end', 'class': 'credit' }, 'Information courtesy of IMDb (https://www.imdb.com)'));
    return svg;
  }
  function niceTicks(lo, hi, n) {
    var raw = (hi - lo) / n, mag = Math.pow(10, Math.floor(Math.log10(raw || 1)));
    var step = [1, 2, 5, 10].map(function (m) { return m * mag; }).filter(function (s) { return s >= raw; })[0] || mag;
    var out = [];
    for (var t = Math.ceil(lo / step) * step; t <= hi + 1e-9; t += step) out.push(Math.round(t));
    return out;
  }
  function monthCounts(entries) {
    var c = []; for (var i = 0; i < 12; i++) c.push(0);
    entries.forEach(function (e) { c[e.month - 1]++; });
    return c;
  }
  function genreCounts(films) {
    var all = []; films.forEach(function (e) { all = all.concat(e.film.genres); });
    return counts(all);
  }

  /* ---------- app ---------- */
  function start(raw) {
    var all = raw;
    var years = []; all.forEach(function (e) { if (years.indexOf(e.year) < 0) years.push(e.year); });
    years.sort(function (a, b) { return b - a; });
    var yearSel = $('dashboard-year'), chartSel = $('dashboard-chart');
    yearSel.appendChild(el('option', { value: 'all' }, 'Tutti gli anni'));
    years.forEach(function (y) { yearSel.appendChild(el('option', { value: y }, y)); });

    var directors = {}, genres = {};
    all.forEach(function (e) {
      e.film.directors.forEach(function (d) { directors[d] = 1; });
      e.film.genres.forEach(function (g) { genres[g] = 1; });
    });
    var dirList = $('dashboard-director-list');
    Object.keys(directors).sort(collator.compare).forEach(function (d) { dirList.appendChild(el('option', { value: d })); });
    Object.keys(genres).sort(collator.compare).forEach(function (g) { $('dashboard-genre').appendChild(el('option', { value: g }, g)); });

    var descriptions = {
      mensili: 'Numero di film in cartellone per mese. Se sono selezionati tutti gli anni, i mesi sono sommati tra gli anni.',
      generi: 'Numero di titoli per genere nella selezione. Un film può appartenere a più generi; i totali quindi si sovrappongono.',
      imdb: 'Una posizione per ogni film distinto con valutazione e voti positivi. Il numero di voti è su scala logaritmica; i dati provengono da IMDb. Passa il puntatore su un punto per vedere il titolo; la tabella dei valori contiene tutti i film.'
    };
    var chartNames = { mensili: 'Film per mese', generi: 'Generi cinematografici', imdb: 'Valutazioni IMDb' };

    var imdbValues = null, entriesTable = pagedTable($('dashboard-table'), [
      { label: 'Data', text: function (e) { return e.date; } },
      { label: 'Titolo', text: function (e) { return e.recorded; }, node: function (e) { return imdbLink(e.recorded, e.film.id); } },
      { label: 'Regia', text: function (e) { return list(e.film.directors); } },
      { label: 'Genere', text: function (e) { return list(e.film.genres); } },
      { label: 'Fonti', text: function (e) { return list(e.sources); } }
    ], { search: true });

    var selected = all, films = uniqueFilms(all);

    function selection() {
      var y = yearSel.value;
      selected = y === 'all' ? all : all.filter(function (e) { return e.year === +y; });
      films = uniqueFilms(selected);
      $('dashboard-entries').textContent = fmt(selected.length);
      $('dashboard-films').textContent = fmt(films.length);
      drawChart(); drawSummary(); drawTable();
    }
    function drawChart() {
      var kind = chartSel.value, box = $('dashboard-chart-box'), vals = $('dashboard-chart-values');
      $('dashboard-chart-description').textContent = descriptions[kind];
      box.setAttribute('aria-label', 'Grafico: ' + chartNames[kind]);
      vals.replaceChildren();
      if (kind === 'mensili') {
        box.replaceChildren(monthChart(selected));
        var c = monthCounts(selected);
        simpleTable(vals, ['Mese', 'Film'], MONTHS.map(function (m, i) { return [m, String(c[i])]; }));
      } else if (kind === 'generi') {
        box.replaceChildren(genreChart(films));
        simpleTable(vals, ['Genere', 'Film'], genreCounts(films).map(function (d) { return [d[0], String(d[1])]; }));
      } else {
        box.replaceChildren(imdbChart(films));
        imdbValues = pagedTable(vals, [
          { label: 'Titolo', text: function (e) { return e.recorded; } },
          { label: 'Valutazione IMDb', text: function (e) { return dec(e.film.rating); }, key: function (e) { return e.film.rating; } },
          { label: 'Voti', text: function (e) { return fmt(e.film.votes); }, key: function (e) { return e.film.votes; } }
        ], { search: true });
        imdbValues.update(ratedFilms(films));
      }
    }
    function rankRows(rows) {
      return rows.map(function (e) {
        return [imdbLink(e.title, e.film.id), list(e.film.directors), dec(e.film.rating), fmt(e.film.votes)];
      });
    }
    function drawSummary() {
      var heads = ['Titolo', 'Regia', 'IMDb', 'Voti'];
      simpleTable($('dashboard-highest'), heads, rankRows(ranking(films, true)));
      simpleTable($('dashboard-lowest'), heads, rankRows(ranking(films, false)));
      var all = []; films.forEach(function (e) { all = all.concat(e.film.directors); });
      simpleTable($('dashboard-directors'), ['Regia', 'Film'], counts(all).slice(0, 5).map(function (d) { return [d[0], String(d[1])]; }));
    }
    function drawTable() {
      var d = $('dashboard-director').value.trim().toLowerCase(), g = $('dashboard-genre').value;
      var rows = selected.filter(function (e) {
        if (d && !e.film.directors.some(function (x) { return x.toLowerCase().indexOf(d) !== -1; })) return false;
        if (g && e.film.genres.indexOf(g) < 0) return false;
        return true;
      });
      entriesTable.update(rows);
    }

    yearSel.addEventListener('change', selection);
    chartSel.addEventListener('change', drawChart);
    $('dashboard-director').addEventListener('input', drawTable);
    $('dashboard-genre').addEventListener('change', drawTable);

    var tabs = Array.prototype.slice.call(root.querySelectorAll('[role="tab"]'));
    function show(tab) {
      tabs.forEach(function (t) {
        var on = t === tab;
        t.setAttribute('aria-selected', on ? 'true' : 'false');
        t.tabIndex = on ? 0 : -1;
        $(t.getAttribute('aria-controls')).hidden = !on;
      });
    }
    tabs.forEach(function (t, i) {
      t.addEventListener('click', function () { show(t); });
      t.addEventListener('keydown', function (ev) {
        var n = ev.key === 'ArrowRight' ? i + 1 : ev.key === 'ArrowLeft' ? i - 1 : ev.key === 'Home' ? 0 : ev.key === 'End' ? tabs.length - 1 : null;
        if (n == null) return;
        ev.preventDefault();
        var next = tabs[(n + tabs.length) % tabs.length]; show(next); next.focus();
      });
    });

    root.querySelector('.dashboard-status').hidden = true;
    root.querySelector('.dashboard-app').hidden = false;
    selection();
  }
})();
