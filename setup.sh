#!/usr/bin/env bash
# Tworzy repozytorium GitHub, projekt Cloudflare Pages (Wrangler) i łączy je przez GitHub Actions.
# Wymaga: git, gh (GitHub CLI), Node.js 18+ (npx).
# Użycie: ./setup.sh [nazwa-repo] [nazwa-projektu-pages]
set -euo pipefail
REPO="${1:-milosierdzie}"
PROJECT="${2:-milosierdzie}"
VISIBILITY="${VISIBILITY:-private}"   # VISIBILITY=public ./setup.sh

for c in git gh npx; do command -v $c >/dev/null || { echo "Brak programu: $c"; exit 1; }; done

echo "== 1/6 Logowanie do GitHub"
gh auth status >/dev/null 2>&1 || gh auth login -w -s repo,workflow

echo "== 2/6 Logowanie do Cloudflare (otworzy się przeglądarka)"
npx -y wrangler@latest whoami >/dev/null 2>&1 || npx -y wrangler@latest login

echo "== 3/6 Projekt Cloudflare Pages: $PROJECT"
npx -y wrangler@latest pages project create "$PROJECT" --production-branch=main || echo "(projekt już istnieje, kontynuuję)"

echo "== 4/6 Lokalne repozytorium"
[ -d .git ] || git init -b main
git add -A
git diff --cached --quiet || git commit -m "Jezu, ufam Tobie: Koronka i Różaniec v1.1.0 (Cloudflare Pages)"

echo "== 5/6 Repozytorium GitHub: $REPO ($VISIBILITY) + sekrety"
git remote get-url origin >/dev/null 2>&1 || gh repo create "$REPO" --"$VISIBILITY" --source=. --remote=origin
echo
echo "Utwórz token API: https://dash.cloudflare.com/profile/api-tokens"
echo "  Create Custom Token -> Permissions: Account / Cloudflare Pages / Edit"
read -rsp "Wklej CLOUDFLARE_API_TOKEN: " CF_TOKEN; echo
read -rp  "Wklej Account ID (panel Cloudflare, prawa kolumna strony Workers & Pages): " CF_ACC
gh secret set CLOUDFLARE_API_TOKEN --body "$CF_TOKEN"
gh secret set CLOUDFLARE_ACCOUNT_ID --body "$CF_ACC"
gh variable set CF_PROJECT --body "$PROJECT"
unset CF_TOKEN

echo "== 6/6 Push -> automatyczne wdrożenie"
git push -u origin main
echo
echo "Gotowe. Postęp: gh run watch   |   Adres: https://$PROJECT.pages.dev"
