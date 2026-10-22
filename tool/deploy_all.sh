#!/bin/bash
# Deploy Worker API + website (static site/) to production, then build a new
# Android bundle. The Flutter web build is NOT the website — don't deploy it.
set -e
cd "$(dirname "$0")/.."
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
echo "== 1/3 Worker API =="; (cd backend/deploy && wrangler deploy)
echo "== 2/3 Website: Pages deploy of site/ (production branch: main) =="; wrangler pages deploy site --project-name=the-utah-view --branch=main --commit-dirty=true
echo "== 3/3 Android bundle =="; flutter build appbundle --release
echo "ALL DONE"
