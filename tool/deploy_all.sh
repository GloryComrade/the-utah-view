#!/bin/bash
# Deploy Worker API + web site to production, then build a new Android bundle.
set -e
cd "$(dirname "$0")/.."
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
echo "== 1/4 Worker API =="; (cd backend/deploy && wrangler deploy)
echo "== 2/4 Flutter web build =="; flutter build web --release
cp web/privacy.html web/delete-account.html build/web/
echo "== 3/4 Pages deploy (production branch: main) =="; wrangler pages deploy build/web --project-name=the-utah-view --branch=main --commit-dirty=true
echo "== 4/4 Android bundle =="; flutter build appbundle --release
echo "ALL DONE"
