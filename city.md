---
title: "NYC Trip Data"
author: "Andrew Bleeda"
date: "4/23/2019"
output: html_document
---


## Intro

This tool allows users to find trip data between any two taxi segments in New York City. There is a web API and a UI app, both using R. To run, install RStudio and download nyc taxi data in your ~/Downloads/ folder.

* https://www.rstudio.com/products/rstudio/download/#download
* https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## UI Usage

Either kick off the UI using a terminal ```Rscript city/app.R``` or go into RStudio and run the city/app.R file. On the left side, select segments and the trip time data will update.

## API Usage

Run the city-api/plumber.R file in RStudio and see the usage docs. There are three endpoints, /list, /table, and /trip, which can be hit via direct URL (curl or similar), or using the swagger app.