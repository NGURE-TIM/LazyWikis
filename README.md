# LazyWikis - MediaWiki Documentation Builder

## User Journey
**START HERE:** Dashboard → Create New Guide → Edit Guide → Download

---

## Innovation lives in the spirit of lazy.

Its literally in the name.

### What Is This?

LazyWikis is a web app that generates clean, structured wikitext for installation guides.

You paste the essentials.
It gives you beautiful, ready-to-use wikitext.

No formatting gymnastics.
No markdown wrestling.
No “wait, how do wiki code blocks work again?”

### What It Does

- Generates structured installation guides
- Formats proper headings, sections, and code blocks
- Turns notes into clean wiki-ready text
- Makes you feel organized

### What It Does NOT Do

- Install your software for you
- Fix your broken dependencies
- Explain why its not working for you
- Replace common sense

We generate documentation.
Miracles are a different product tier.

### Philosophy

If you have to do something more than twice, automate it.
If automation takes longer than the task — do it anyway.


### Credits

Special thanks to my junior devs:

- **Gemini** – occasionally overconfident, frequently helpful
- **Claude** – structured, thoughtful, has a weird tendancy to... well you'll see

Together, they helped transform
“I need to write docs…”
into
“Hold on, let me generate that.”

If you’re still writing installation guides manually…

That’s brave.

---

## Installation & Usage

### Option 1: Docker (Suspiciously Recommended)

Run LazyWikis instantly with Docker:

```bash
docker build -t lazywikis .
docker run -p 8080:80 lazywikis
```

Open your browser to `http://localhost:8080`.

### Option 2: Local Development

Please just use docker
