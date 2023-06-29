#!/bin/bash
jekyll doctor
jekyll clean && jekyll server --host=0.0.0.0 --incremental
