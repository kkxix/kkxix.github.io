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
    url: z.string().url(),
    byline: z.string(),
    type: z.enum(['article','report','toolkit','talk']),
    takeaway: z.string().optional(),
  }),
});

export const collections = { projects, writing };
