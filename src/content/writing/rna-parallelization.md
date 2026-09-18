---
title: "Parallelizing the RNA Secondary Structure Dynamic Programming Problem"
outlet: "Swarthmore College, CS87 — presented at CCSCNE 2022"
date: 2021-12-01
pdf: "/pdfs/publications/rna-parallelization-cs87.pdf"
byline: "Third of four authors"
authors: ["Tillie Ferguson","Alice Huang","Katie Knox","Sojin Lim"]
type: poster
peerReviewed: false
venueNote: "Course project report; presented as a poster at CCSCNE 2022, not peer reviewed"
takeaway: "Two parallel implementations of Nussinov's algorithm, one shared-memory in CUDA and one distributed in MPI. CUDA gives the larger speed-up but tapers off due to implementation overhead, while the MPI column-based version scales better as processor count rises."
---
