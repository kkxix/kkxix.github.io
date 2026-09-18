import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const TAGS   = ['planning','analytics','data-science','software','research','writing'] as const;
const THEMES = ['digital-equity','climate-risk','critical-data','philadelphia','housing','transport'] as const;

const projects = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/projects' }),
  schema: ({ image }) => z.object({
    title: z.string(),
    summary: z.string(),                       // one sentence
    date: z.date(),
    tags: z.array(z.enum(TAGS)).min(1),
    themes: z.array(z.enum(THEMES)).default([]),
    featured: z.boolean().default(false),
    status: z.enum(['complete','in-progress']),
    kind: z.enum(['analysis','plan','tool','research','writing']),
    role: z.string().optional(),               // empty + AUTHOR marker if unknown
    collaborators: z.array(z.string()).optional(),
    course: z.string().optional(),
    cover: image(),
    stat: z.object({ value: z.string(), label: z.string() }).optional(),
    // Converted Jupyter notebooks in public/reports/<slug>/<file>.html
    notebooks: z.array(z.object({
      file: z.string(),
      title: z.string(),
      note: z.string().optional(),
    })).optional(),
    // Page-image count for PdfEmbed's narrow-screen fallback
    pdfPages: z.number().int().positive().optional(),
    links: z.object({
      code: z.string().url().optional(),
      report: z.string().optional(),
      slides: z.string().optional(),
      pdf: z.string().optional(),
      live: z.string().url().optional(),
    }).default({}),
  }),
});

const writing = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/writing' }),
  schema: z.object({
    title: z.string(),
    outlet: z.string(),
    date: z.date(),
    // Either an external URL, a local PDF under public/, or both.
    url: z.string().url().optional(),
    pdf: z.string().optional(),
    byline: z.string(),
    authors: z.array(z.string()).optional(),
    // 'preprint' and 'poster' are deliberately distinct from 'article':
    // neither has been through peer review, and the page says so.
    type: z.enum(['article','report','toolkit','talk','preprint','poster']),
    peerReviewed: z.boolean().default(false),
    takeaway: z.string().optional(),
    venueNote: z.string().optional(),
  }).refine((d) => d.url || d.pdf, { message: 'writing entries need a url or a pdf' }),
});

export const collections = { projects, writing };
