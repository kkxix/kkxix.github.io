# kkxix.github.io

Portfolio site. Astro + MDX, TypeScript strict, plain CSS with custom properties.
Deployed to GitHub Pages by `.github/workflows/deploy.yml` on push to `main`.

## Running it

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # guards + astro build + size check
npm run preview  # serve the built site
npm run check    # run the guards alone
```

**Astro 7 runs `astro dev` as a daemon.** `Ctrl-C` or `pkill` does not reliably stop
it, and a stale server will keep serving old content — including silently ignoring a
new content collection. Use `npx astro dev stop` before restarting, or you will chase
changes that appear not to apply.

Changes to `src/content.config.ts` in particular may not reach the dev server even
after a restart. When dev and `npm run build` disagree, **trust the build**: run
`npm run build && npm run preview` and check there. That is what actually deploys.

## Build guards

`npm run build` fails if either guard trips:

- `scripts/check-content.mjs` — fails if excluded terms appear in any page or content
  body. Covers the MAS / water-resilience work, djemkati, and the plurilateral paper.
- `scripts/check-size.mjs` — fails on any file over 50 MB in `public/` or `dist/`.

The content schema in `src/content.config.ts` also fails the build on any frontmatter
violation: tags, themes, `status` and `kind` are enums, so a typo stops the build
rather than silently producing an unfiltered project.

## Adding a project

1. Create `src/content/projects/<slug>.mdx` with the frontmatter the schema requires
   (`title`, `summary`, `date`, `tags`, `status`, `kind`, `cover`).
2. Put the cover image in `src/assets/plates/` — Astro converts and resizes it, so
   commit the full-resolution figure rather than a hand-shrunk one.
3. The page appears at `/work/<slug>`, in `/work`, and under each of its tag pages.

## Embedding reports

Rendered analyses live in `public/reports/<slug>/index.html` and are framed by
`ReportFrame`.

- **Quarto**: render with `embed-resources: true` so the output is one self-contained
  file, then copy it in. Without that flag the HTML depends on a sibling `_files`
  directory and will deploy broken.
- **Jupyter notebooks**: use `./scripts/notebooks-to-html.sh <notebook-dir> <slug>`,
  which converts every notebook in a directory to self-contained HTML in
  `public/reports/<slug>/`. It strips `metadata.widgets` into a temp copy first:
  notebooks carrying stale widget metadata without a `state` key crash nbconvert
  with `KeyError: 'state'`. Source notebooks are never modified. Notebooks
  containing Folium maps pull Leaflet from a CDN at view time.

  Declare them in the project's frontmatter and `NotebookSet` embeds the whole set
  inline, each in a `<details>` so it works without JavaScript and closed notebooks
  cost nothing to load:

  ```yaml
  notebooks:
    - { file: "0201_RF", title: "Random forest flood detection", note: "SAR and optical" }
  ```

Link the report with an **explicit `index.html`**:

```yaml
links: { report: "/reports/<slug>/index.html" }
```

Astro's dev server does not resolve a directory URL in `public/` to its `index.html`,
though GitHub Pages does. A bare directory path works in production and 404s locally.

## Embedding PDFs

```bash
./scripts/pdf-to-pages.sh path/to/file.pdf <slug> [first] [last]
```

Writes page images and a compressed PDF to `public/pdfs/<slug>/`. `PdfEmbed` shows the
inline viewer on desktop and the page images on narrow screens. Ghostscript is
optional; without it the PDF is copied uncompressed. The script warns above 20 MB.

## Design

Tokens are in `src/styles/tokens.css`. The light palette is defined on bare `:root`;
dark is redefined both under `prefers-color-scheme` and under `[data-theme="dark"]`,
so a future toggle wins in either direction. Layout is responsive to 360 px, focus
states are visible, and reduced motion is respected.

`AuthorTodo` renders a visible amber box in `astro dev` and nothing in production, so
missing narrative is obvious while previewing but never ships.

## Outstanding

Narrative gaps are marked `{/* AUTHOR: … */}` in content and tracked in
`NARRATIVE_TODO.md`. The display name is still the token `[NAME]`.
