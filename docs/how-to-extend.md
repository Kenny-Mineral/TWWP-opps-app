# How to Extend — Adding New Pages, Data, and Features

This guide walks through the concrete steps for the most common types of changes. Every example follows the patterns already used in the app.

---

## Before you start any change

1. **Read architecture.md** — especially the iOS Safari rules. Breaking those causes silent failures on mobile.
2. **Work in a copy.** Save `index.html` as `index-backup-YYYYMMDD.html` before starting.
3. **Validate after every significant change.** Open the file in a browser, open DevTools (F12), and check the Console for errors. Any JavaScript syntax error will stop the whole app.
4. **Use `data-` attributes for onclick handlers in dynamically-built HTML.** Never put single quotes inside a JS string that itself uses single quotes. See the pattern below.

---

## The safe onclick pattern

This is the pattern that works reliably and avoids quote-escaping problems:

```javascript
// SAFE: use data attribute + this.dataset
html += '<button data-xid="' + esc(item.id) + '" onclick="deleteItem(this.dataset.xid)">Del</button>';

// UNSAFE: never do this — breaks iOS Safari and Node syntax checking
html += '<button onclick="deleteItem(\'' + item.id + '\')">Del</button>';
```

---

## How to add a new page

A "page" in this app is just a `<div class="page" id="page-YOURPAGENAME">`. Adding one takes five steps.

### Step 1: Add the HTML for the page

Find the area in the HTML body where pages live (around line 700 onwards). Add your page div in the appropriate section:

```html
<!-- ====== YOUR NEW PAGE ====== -->
<div class="page" id="page-yourpage">
  <div class="ph">
    <div>
      <div class="ph-ey">Section Name</div>
      <div class="ph-title">Your Page Title</div>
    </div>
    <div class="ph-right">
      <button class="btn btn-p btn-sm" onclick="openYourMo()">+ Add Thing</button>
    </div>
  </div>
  <div class="pb">
    <!-- Page content goes here -->
    <div id="yourPageContent"></div>
  </div>
</div>
```

The CSS classes used here:
- `.ph` — page header (sticky at top)
- `.ph-ey` — small eyebrow label above the title
- `.ph-title` — main page title
- `.ph-right` — right-aligned actions in the header
- `.pb` — page body (scrollable content area)

### Step 2: Add the sidebar navigation item

Find the sidebar HTML (around line 700 in the `<nav>` area). Add your item inside the appropriate `<div class="sb-sect">` section:

```html
<div class="sb-item" id="ni-yourpage" onclick="go('yourpage', this)">
  <span class="sb-icon">&#128203;</span>
  <span class="sb-lbl">Your Page Name</span>
</div>
```

Pick an emoji for the icon from any emoji reference. The `id="ni-yourpage"` is used by the navigation system to highlight the active sidebar item.

### Step 3: Register the page in the `go()` function

Find the `go(page, el)` function in the JavaScript section (around line 1478). Add your page to the list of pages that need special initialisation when first opened. If your page just renders a list, add it here:

```javascript
function go(page, el) {
  // ... existing code ...
  
  // Add your page's initialiser:
  if (page === 'yourpage') renderYourPage();
  
  // ... rest of function ...
}
```

If your page doesn't need any special setup, you don't need to add anything here — it will just show the static HTML.

### Step 4: Add a render function

In the JavaScript section, add a function that populates your page:

```javascript
function renderYourPage() {
  const el = G('yourPageContent');
  if (!el) return;
  
  const items = S.get('yourstore'); // get data
  
  if (!items.length) {
    el.innerHTML = '<div class="es"><div class="ei">&#128203;</div><h3>Nothing here yet</h3><p>Add something to get started.</p></div>';
    return;
  }
  
  let html = '';
  items.forEach(function(item) {
    html += '<div class="card" style="padding:14px">';
    html += '<div style="font-weight:700">' + esc(item.name) + '</div>';
    html += '<button data-xid="' + esc(item.id) + '" onclick="deleteYourItem(this.dataset.xid)">Delete</button>';
    html += '</div>';
  });
  el.innerHTML = html;
}
```

### Step 5: Add a data store (if needed)

If your page needs its own data, add:

1. A key to the `KS` object (around line 1415):
```javascript
const KS = {
  // ... existing keys ...
  yourstore: 'twwp_yourstore_v1',   // add this line
};
```

2. Seed with an empty array in `seedDemoData()` if needed (it's already handled automatically — `S.get()` returns `[]` if nothing is stored yet).

---

## How to add a modal (pop-up form)

Every add/edit form in the app is a modal. Here's the pattern.

### Step 1: Add the modal HTML

Add this somewhere in the body, **before** the `<div id="appRoot">` tag:

```html
<!-- YOUR THING MODAL -->
<div class="mo" id="yourMo">
  <div class="md">
    <div class="md-h">
      <div class="md-t" id="yourMoT">// ADD THING</div>
      <button class="md-x" onclick="CM('yourMo')">x</button>
    </div>
    <div class="md-b">
      <div class="fg"><label>Name *</label><input type="text" id="yt-name" placeholder="Enter name"></div>
      <div class="fg"><label>Notes</label><textarea id="yt-notes" rows="3"></textarea></div>
      <div style="display:flex;gap:8px;justify-content:flex-end">
        <button class="btn btn-g btn-sm" onclick="CM('yourMo')">Cancel</button>
        <button class="btn btn-p btn-sm" onclick="saveYourThing()">Save</button>
      </div>
    </div>
  </div>
</div>
```

CSS classes used:
- `.mo` — the overlay background
- `.md` — the modal dialog box
- `.md-h` — modal header
- `.md-t` — title text
- `.md-x` — close button
- `.md-b` — modal body (scrollable content)
- `.fg` — form group (label + input, stacked)

### Step 2: Add open and save functions

```javascript
let editYourThingId = null;

function openYourMo() {
  editYourThingId = null;
  G('yourMoT').textContent = '// ADD THING';
  G('yt-name').value = '';
  G('yt-notes').value = '';
  OM('yourMo');
}

function editYourThing(id) {
  const item = S.find('yourstore', id);
  if (!item) return;
  editYourThingId = id;
  G('yourMoT').textContent = '// EDIT THING';
  G('yt-name').value = item.name || '';
  G('yt-notes').value = item.notes || '';
  OM('yourMo');
}

function saveYourThing() {
  const name = G('yt-name').value.trim();
  if (!name) { alert('Name is required.'); return; }
  
  S.upsert('yourstore', {
    id: editYourThingId || uid(),
    name: name,
    notes: G('yt-notes').value.trim(),
    created: editYourThingId
      ? (S.find('yourstore', editYourThingId)?.created || new Date().toISOString())
      : new Date().toISOString()
  });
  
  CM('yourMo');
  renderYourPage();
}

function deleteYourThing(id) {
  if (!confirm('Delete this item?')) return;
  S.rm('yourstore', id);
  renderYourPage();
}
```

---

## How to add a new field to an existing data type

For example, adding a "phone number" field to locations.

1. **Add the input to the location modal HTML** — find `id="locMo"` and add a field group
2. **Add it to `saveLoc()`** — include the new field in the `S.upsert()` call
3. **Add it to `editLoc()`** — pre-fill the field when opening for editing
4. **Add it to `renderLocs()`** — display it in the location cards
5. **Existing records** — records already saved won't have the field, so always use `item.phone || ''` rather than just `item.phone` to avoid errors

---

## How to add a new capture type

The Capture Widget (the `+` button) saves items to the `captures` store. To add a new capture type:

1. **Add a menu item** in the capture menu HTML (find `id="captureMenu"`):
```html
<button class="cap-menu-item" onclick="openCaptureMo('yourtype')">🔧 Your Type</button>
```

2. **Add any type-specific form fields** in `updateCaptureForm()`:
```javascript
function updateCaptureForm() {
  const type = G('cap-type').value;
  const extra = G('cap-extra');
  if (!extra) return;
  
  if (type === 'yourtype') {
    extra.innerHTML = '<div class="fg"><label>Your Field</label><input type="text" id="cap-yourfield"></div>';
  } else if (type === 'feedback') {
    // existing feedback logic
  } else {
    extra.innerHTML = '';
  }
}
```

3. **Add a page that displays items of this type** — filter the `captures` store by `type === 'yourtype'`

---

## How to add an item to the sidebar

The sidebar has sections defined by `<div class="sb-sect">YOUR SECTION</div>` headings. To add a new item to an existing section, just add a `sb-item` div before the closing tag of that section group.

To add a **new section**:
```html
<div class="sb-sect">MY NEW SECTION</div>
<div class="sb-item" id="ni-newpage" onclick="go('newpage', this)">
  <span class="sb-icon">&#128203;</span>
  <span class="sb-lbl">New Page</span>
</div>
```

---

## How to add demo data

All demo data is seeded in the `seedDemoData()` function (around line 2523). The function only runs once — it checks `localStorage.getItem('twwp_demo_seeded_v3')` and returns early if it's already been set.

To add demo records for a new store, add `S.upsert('yourstore', { ... })` calls inside `seedDemoData()`.

When you want demo data to re-seed during development, either:
- Open DevTools → Application → Local Storage → delete `twwp_demo_seeded_v3`, then reload
- Or use the "Clear Demo Data" button in the sidebar (this clears data but also removes the flag)

To clear only the seed flag without clearing data (useful during testing):
```javascript
// In browser console:
localStorage.removeItem('twwp_demo_seeded_v3')
```

---

## How to update the statistics bar

The statistics bar at the top of the screen shows counts of records. The function `updStats()` (around line 1508) populates it. If you add a new data store that should appear in the stats bar, add it here:

```javascript
function updStats() {
  // ... existing stats ...
  
  const yourCount = S.get('yourstore').length;
  const el = G('stat-yourstore');
  if (el) el.textContent = yourCount;
}
```

Then add the corresponding HTML element in the stats bar area.

---

## How to add a filter pill bar

Filter pills are the row of clickable buttons like "All / Electronics / Sensors / Filtration" that filter what's shown. The pattern:

**HTML:**
```html
<div class="pills" id="yourFilterPills">
  <div class="pill on" data-t="" onclick="setPill(this,'yourFilterPills','yourFilterState');renderYourPage()">All</div>
  <div class="pill" data-t="typeA" onclick="setPill(this,'yourFilterPills','yourFilterState');renderYourPage()">Type A</div>
  <div class="pill" data-t="typeB" onclick="setPill(this,'yourFilterPills','yourFilterState');renderYourPage()">Type B</div>
</div>
```

**JavaScript:**
```javascript
let yourFilterState = '';  // add this with the other state variables near line 1462

function renderYourPage() {
  let items = S.get('yourstore');
  if (yourFilterState) {
    items = items.filter(function(i) { return i.type === yourFilterState; });
  }
  // ... render items ...
}
```

The `setPill()` utility handles highlighting the active pill and setting the state variable automatically.

---

## How the print / PDF system works

Reports and receipts use `window.open()` to create a new browser window with clean HTML, then call `window.print()` on it after a short delay. The user gets the browser's native print dialog, and can choose "Save as PDF".

To create a new printable document, follow the pattern in `printMaintReport()`:

```javascript
function printMyDoc() {
  const content = G('myDocBody').innerHTML;
  if (!content) return;
  
  const w = window.open('', '_blank');
  w.document.write('<html><head><title>My Doc</title><style>');
  w.document.write('body { font-family: Georgia, serif; max-width: 700px; margin: 20px auto; }');
  w.document.write('@media print { button { display: none; } }');
  w.document.write('</style></head><body>');
  w.document.write(content);
  w.document.write('</body></html>');
  w.document.close();
  w.focus();
  setTimeout(() => w.print(), 500);
}
```

The 500ms delay before `print()` gives the browser time to render the new window's content before triggering the print dialog.

---

## General tips

- **Always use `esc(value)`** when inserting any user-entered data into `innerHTML`. Without this, a name like `O'Brien` or a note containing `<b>bold</b>` will break the HTML.
- **Never use `let` or `const` to redeclare a variable that already exists in the file.** Use `var` or just assign to an already-declared variable. The file is one long script scope.
- **Test on mobile** after any layout changes. The app needs to work on iOS Safari. Use Chrome DevTools device emulation as a first check.
- **Keep functions near their related functions.** The file is long — grouping related functions makes it manageable.
- **Add a helper bubble** to any new page you build. This is the blue info box that explains what the page does. Use the `.helper-bubble` CSS class.
