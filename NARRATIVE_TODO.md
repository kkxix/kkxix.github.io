# Narrative TODO — site

## Roles — answered 2026-09-18
All seven projects now carry a role, confirmed by the owner. Home value was taken
from the commit history at the owner's direction; the rest were stated directly.

## Blocking the site going live
- [ ] src/pages/index.astro:§banner — positioning statement, the first thing a reader sees
- [ ] layout + page titles — decide the display name and replace the `[NAME]` token
- [ ] src/pages/about.astro:§bio — two or three paragraphs
- [ ] src/pages/about.astro:§contact — which contact details the site carries
- [ ] src/pages/about.astro:§cv — export CV to PDF into public/cv/ and link it

## Per project
- [ ] Nairobi notebooks 0302 and 0303 were run on Colab and saved with no outputs.
      Every copy on disk and in git history is code-only. If the executed versions
      still exist in a Colab account, re-saving them with outputs would let the
      notebooks render in full instead of relying on the Results gallery
- [ ] philadelphia-wifi-access — rewrite the opening from results_summary.md
- [ ] nairobi-flood-mapping — why flood mapping matters for Nairobi
- [ ] philadelphia-home-value-model — summary from a fresh render
- [ ] philadelphia-eviction-model — summary; settle the ethics question first
- [ ] indego-demand-forecast — summary drawing on the critical reflection

## Publications
- [ ] The NDNC report carries no individual bylines — it is institutionally authored
      by NDIA. The site states the role as "Data analysis and contributing author"
      from the owner's own account. Confirm that wording is one NDIA would recognise
- [ ] The RNA paper is hosted here as a PDF; it has no other public home. Confirm the
      three co-authors (Tillie Ferguson, Alice Huang, Sojin Lim) are content for the
      course report to be published on a personal site
- [ ] Resume cites the RNA author order as "Huang, Ferguson, Knox, Lim" but the paper
      itself reads "Tillie Ferguson, Alice Huang, Katie Knox, Sojin Lim". The site
      uses the paper. Confirm which is right
- [ ] Resume cites the RNA poster as CCSCNE 2022; the PDF is a CS87 course report.
      Site says both. Confirm the poster date

## Blocked on OneDrive
- [ ] Bustleton plan book PDF cannot be embedded yet: the source file went dataless
      again and OneDrive stopped materialising files mid-session. Once it is back,
      run `./scripts/pdf-to-pages.sh "<path>/Bustleton_Book.pdf" bustling-bustleton`
      and add `links: { pdf: ... }` plus `pdfPages: 105` to the project entry.
      Note the source is 56 MB; check the compressed size against the 20 MB rule.

## Decisions
- [ ] Which repositories become public, and when (all six are private and carry open AUTHOR markers)
- [ ] Co-author consent: home value + eviction (Abraham, Levin), Nairobi (Xu, Ezra),
      Bustleton (five collaborators), East Passyunk (four collaborators)
