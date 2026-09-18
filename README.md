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

Writes page images and a ghostscript `/ebook` copy to `public/pdfs/<slug>/`, then
converts the page images to WebP if `cwebp` is available. That conversion matters:
the 105-page Bustleton plan book came to **47 MB as PNG and 9.6 MB as WebP**, at
visually identical quality. The script prints the page count to put in `pdfPages`,
and warns if the PDF is still over 20 MB.

Two display modes, set with `pdfDisplay` in the project frontmatter:

- `viewer` (default) — `PdfEmbed`, an inline PDF viewer on desktop with the page
  images as the narrow-screen fallback. Good for portrait documents.
- `spread` — `PdfSpread`, facing pages side by side from the page images, cover
  alone. Use for landscape documents laid out as spreads: the Bustleton plan book
  has diagrams that run across a two-page spread and are cut in half if shown one
  page at a time. Collapses to one page per row below 60rem.

```yaml
links: { pdf: "/pdfs/<slug>/<slug>.pdf" }
pdfPages: 105
pdfDisplay: spread
```

## The CV

`src/pages/cv.astro` holds the CV as structured content, and
`./scripts/build-cv-pdf.sh` prints `public/cv/katie-knox-cv.pdf` from that page
with headless Chrome. The download is generated from the page, so the two cannot
drift apart — edit the page, re-run the script.

Print styles in the layout hide the navigation rail, so the PDF is the document
rather than a screenshot of the site.

## Design

Tokens are in `src/styles/tokens.css`. The palette is six brand colours plus
neutrals derived from the indigo hue so they stay in family.

**Contrast governs which colour does what.** Measured against the light ground,
only electric indigo (6.17:1) passes AA for body text; medium slate blue (4.35:1)
is large-text and UI only, and chartreuse (1.14:1), plum (1.89:1) and blaze
orange (2.89:1) are fills only and must never carry small text on white. The
orange is darkened to #d0570f where it needs to be legible on light. On the dark
ground the order inverts: chartreuse (16.07:1), plum (9.72:1) and orange (6.35:1)
all pass, while indigo is too dark and is used as a ground instead.

**Chartreuse is never text.** It exists only as `--highlight-bg`, a background for
highlighted boxes and legend swatches, with `--highlight-ink` on top of it
(16.07:1). At 1.14:1 on white it is invisible as a text colour, so there is no
`--highlight` text token at all — the name would invite the mistake.

Type is Helvetica for headings and body, monospace for the all-caps labels. The
stack resolves to real Helvetica Neue or Helvetica where installed, Arial on
Windows and Liberation Sans on Linux — all metrically compatible — so no webfont
is loaded and there is no flash of unstyled text. If identical rendering
everywhere matters more than that, self-host Inter or Arimo and put it at the
front of `--face-text`.

Tokens are named by role — `--accent`, `--accent-soft`, `--highlight-bg`,
`--highlight-ink`, `--warn`, `--plum` — rather than by colour, so the same
component works in both themes. The light palette is defined on bare `:root`;
dark is redefined both under `prefers-color-scheme` and under `[data-theme="dark"]`,
so a future toggle wins in either direction. Layout is responsive to 360 px, focus
states are visible, and reduced motion is respected.

`AuthorTodo` renders a visible amber box in `astro dev` and nothing in production, so
missing narrative is obvious while previewing but never ships.

## Outstanding

Narrative gaps are marked `{/* AUTHOR: … */}` in content and tracked in
`NARRATIVE_TODO.md`. The display name is still the token `[NAME]`.
