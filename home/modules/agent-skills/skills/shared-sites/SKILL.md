---
name: shared-sites
description: Build and deploy static sites/apps for the self-hosted "shared" platform (github.com/sdelcore/shared, served at *.shared.tap). Use when the user wants to build a site/app that uses shared's client API — its document DB, AI chat, file uploads, websocket channels, or identity — or asks to deploy a site to shared. Covers the /shared.js API, the deploy flow, subdomain routing, and the platform's constraints.
---

# Building sites for `shared`

`shared` is a single Go server (`sharedd`) that hosts many static sites under
subdomain routing and gives each one a batteries-included client API via a
single `<script src="/shared.js">`. A site is just static files (HTML/CSS/JS) —
no build step required, no backend to write. The platform provides the backend:
a document DB with realtime, an AI chat proxy, uploads, websocket channels, and
identity.

Homelab deployment: server at `shared.tap` (10.0.0.24); sites live at
`https://<name>.shared.tap/`.

## Hard constraints (design the site around these)

- **No auth. Single user, trusted-network only.** Anyone who can reach the
  server can read/write everything. Never build login/permissions on top of it
  and never put it on the public internet. Don't store secrets in site data.
- **Per-site data isolation.** `db`, `uploads`, and `ws` are scoped to the
  site's subdomain (first Host label) automatically — one site can't read
  another's data. You never pass the site name in client code.
- **Site names** must match `^[a-z0-9][a-z0-9-]{0,62}$`.

## Minimal site

```html
<!-- index.html -->
<!doctype html><meta charset="utf-8"><title>My App</title>
<script src="/shared.js"></script>
<body>
  <ul id="list"></ul>
  <script>
    const todos = shared.db.collection('todos');
    async function render() {
      const items = await todos.list();
      list.innerHTML = items.map(t => `<li>${t.text}</li>`).join('');
    }
    todos.subscribe(render);          // realtime: re-render on any change
    render();
    todos.create({ text: 'first todo' });
  </script>
</body>
```

## Client API (`/shared.js`) — everything is scoped to the current site

### `shared.db` — JSON document store (server-managed `id`, `createdAt`, `updatedAt`)
```js
const posts = shared.db.collection('posts');
const doc = await posts.create({ title: 'hi', body: '...' });
const all = await posts.list();          // sorted by createdAt
const one = await posts.get(doc.id);
await posts.update(doc.id, { title: 'hello' });
await posts.delete(doc.id);
const off = posts.subscribe(e => { /* e.type: created|updated|deleted, e.doc */ });
```

### `shared.ai` — AI chat proxy (key + model live on the server)
```js
const reply = await shared.ai.chat('Summarize this in one line: ...');
// full control:
const res = await shared.ai.chat({ messages: [{ role: 'user', content: '...' }], system: '...' });
```
The model is configured server-side (`SHARED_AI_MODEL`) — don't hardcode model
names in site code unless the user explicitly wants to override per-call.

### `shared.uploads` — file uploads
```js
const { url } = await shared.uploads.upload(fileInput.files[0]);  // url is servable
```

### `shared.ws` — websocket channels (realtime pub/sub between visitors)
```js
const room = shared.ws.channel('lobby');
room.onmessage = msg => { /* ... */ };
room.send({ hello: 'world' });
```

### `shared.identity` — current user
```js
const me = await shared.identity();   // { email, name }
```

## Deploy

From the site directory (rsync-style; redeploy overwrites):
```sh
shared deploy <dir> --name <site-name>
# e.g. shared deploy ./mysite --name mysite  ->  https://mysite.shared.tap/
```
The homepage (`https://shared.tap/`) lists all deployed sites.

## Tips

- Keep it a static site — let `shared.db`/`ai`/`uploads`/`ws` be the backend.
- Use `subscribe` for live UIs instead of polling.
- Build the whole feature client-side; there is no server code to add.
