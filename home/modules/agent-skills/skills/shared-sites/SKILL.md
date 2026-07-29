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
    // realtime: re-render on any change (handlers object, NOT a bare callback)
    todos.subscribe({ onCreate: render, onUpdate: render, onDelete: render });
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

// subscribe takes a HANDLERS OBJECT, not a callback. A bare function is
// accepted and then silently never fires — the most common way to ship a
// dead realtime UI here.
const sub = posts.subscribe({
  onCreate: doc => {},
  onUpdate: doc => {},
  onDelete: doc => {},   // receives { id } on reconnect-replay, the full doc live
});
sub.close();             // returns { close }, not an unsubscribe function
```
Each handler receives the document itself — there is no event wrapper, so no
`e.type` / `e.doc`. The socket resyncs on reconnect and replays whatever was
missed through the same handlers.

### `shared.ai` — AI chat proxy (key + model live on the server)
```js
// chat(messages, opts) — two positional args. A string is wrapped for you.
const reply = await shared.ai.chat('Summarize this in one line: ...');

const reply2 = await shared.ai.chat(
  [{ role: 'user', content: '...' }],
  { system: '...', model: '...', max_tokens: 1024 },
);
// returns the assistant's text (res.content), already unwrapped.

// streaming — prefer this for anything long, and required for models that
// only support streaming (some chatgpt/* routes via LiteLLM). Still resolves
// to the full text at the end.
const full = await shared.ai.chat(q, { stream: true, onToken: t => out.append(t) });

const { url } = await shared.ai.image('a red bicycle', { size: '1024x1024' });
```
Do NOT pass a single options object as the first argument — `{ messages, system }`
is sent as the message list and the call fails.

The model is configured server-side (`SHARED_AI_MODEL`; on this homelab it is
`services.shared.aiModel` in `homelab/nixos/hosts/shared.nix`) — don't hardcode
model names in site code unless the user explicitly wants to override per-call.
It must name a model the LiteLLM gateway actually serves; a stale value makes
every `chat()` call fail with a 400 that only shows up at request time.

### `shared.uploads` — file uploads
```js
const { url } = await shared.uploads.upload(fileInput.files[0]);  // url is servable
```

### `shared.ws` — websocket channels (realtime pub/sub between visitors)
```js
const room = shared.ws.channel('lobby');
room.onMessage(msg => { /* ... */ });   // a METHOD; `room.onmessage = fn` does nothing
room.send({ hello: 'world' });          // JSON-encoded for you
room.close();
```
`onMessage` can be called more than once — every registered listener gets each
message. Incoming payloads are JSON-parsed when possible, else passed as a string.

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
- The served `/shared.js` is the source of truth for signatures, and it moves
  ahead of this file. `curl https://<site>.shared.tap/shared.js` and read the
  function you're about to call — the callback-shaped APIs (`db.subscribe`,
  `ws.channel`) fail silently when called wrongly, so a mismatch looks like
  "the feature doesn't work" rather than an error.
- Smoke-test the platform calls against the real server before assuming the
  site is at fault: `curl -X POST https://<site>.shared.tap/api/db/<col> -H
  'Content-Type: application/json' -d '{}'` and the same for `/api/ai/chat`.
