# Jezu, ufam Tobie – Koronka i Różaniec

Aplikacja WEB + PWA (vanilla JS, jeden plik `public/index.html`), hostowana na Cloudflare Pages.
Każdy `git push` na `main` wdraża stronę przez GitHub Actions + Wrangler.

## Pierwsze uruchomienie
```bash
./setup.sh                      # repo "milosierdzie", projekt Pages "milosierdzie", repo prywatne
VISIBILITY=public ./setup.sh moje-repo moj-projekt
```
Skrypt: loguje do GitHub i Cloudflare, tworzy projekt Pages (Wrangler), tworzy repo,
zapisuje sekrety `CLOUDFLARE_API_TOKEN` i `CLOUDFLARE_ACCOUNT_ID`, robi push.
Windows: uruchom w Git Bash lub WSL.

## Struktura
- `public/` – to, co trafia na serwer (`_headers` = nagłówki Cloudflare)
- `wrangler.toml` – konfiguracja Pages
- `.github/workflows/deploy.yml` – wdrożenie przy każdym pushu (gałęzie inne niż `main` dostają podgląd)

## Obraz i APK
- `public/img/jezu-milosierny.webp` – obraz tła (482×1051). Przy wymianie obrazu popraw `CONFIG.bgSize` i `CONFIG.heart` w `index.html`
- `public/download/milosierdzie.apk` – z pwabuilder.com (Android) po pierwszym wdrożeniu; limit pliku na Pages: 25 MB

## Każde wdrożenie
Podbij `APP_VERSION` w `public/index.html` i `VERSION` w `public/sw.js`, potem:
```bash
git commit -am "v1.0.1" && git push
```
Ręcznie, bez GitHuba: `npx wrangler pages deploy`
