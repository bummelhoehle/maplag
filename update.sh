#!/bin/bash -e
mv ~/Downloads/index.html .
git add index.html
git commit -m "bug fix"
git push
