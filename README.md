# winsnes.io

This repository contains the files for the winsnes.io blog. As an experiment I'm making the source code for the blog open source so everyone can see what is happening behind the scenes, as well as blogging about the process and experience. I'm intending to build this out with fully automated solutions for building, testing, and deploying the blog. It will be a lot of work but, it will be interesting to see how far I can push a fully open blogging solution, and if there will be any issues as I build.

## Tools in use

These are the tools that are currently in use on this project. This will change over time as the project evolves.

- Hugo - static blogging platform
- Hashicorp Terraform
- Google Cloud Platform - SDK and services

## Generating the static blog

To generate the blog, change to the blog directory and call the `hugo` command

```sh
hugo
```

This will generate HTML, JS, and CSS files for the site and put them in the `blog/public/` folder. Upload these files to a static hosting solution to publish the site.
