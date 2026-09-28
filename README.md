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

## Obraz
- `public/img/jezu-milosierny.webp` – obraz tła (482×1051). Przy wymianie obrazu popraw `CONFIG.bgSize` i `CONFIG.heart` w `index.html`

## Aplikacja natywna (APK) i PWA
- **PWA**: `manifest.webmanifest` + `sw.js`; przycisk „Pobierz aplikację PWA” wywołuje instalację przeglądarki
  (Android/komputer) albo pokazuje instrukcję dla iPhone’a.
- **APK**: `native/` (Capacitor) opakowuje `public/` w aplikację Android działającą offline; lektor używa
  natywnego syntezatora mowy Androida, ekran nie gaśnie w trybie automatycznym.
  GitHub Actions buduje APK przy każdym wdrożeniu (`native/build-apk.sh`) i umieszcza je w
  `public/download/milosierdzie.apk` – pod przyciskiem „Pobierz aplikację natywną (APK)”.
  APK jest też dostępne jako artefakt uruchomienia w zakładce Actions.
- **Klucz podpisu** (zalecane; bez niego APK jest podpisane kluczem tymczasowym i każda aktualizacja
  wymaga odinstalowania poprzedniej wersji). Jednorazowo (JDK: `keytool`):
  ```bash
  keytool -genkeypair -v -keystore milosierdzie.keystore -alias milosierdzie -keyalg RSA -keysize 2048 -validity 10000
  base64 -w0 milosierdzie.keystore > keystore.txt        # Windows: certutil -encode milosierdzie.keystore keystore.txt
  ```
  Sekrety repozytorium: `ANDROID_KEYSTORE_BASE64` (zawartość keystore.txt; przy certutil bez linii BEGIN/END),
  `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`milosierdzie`), `ANDROID_KEY_PASSWORD`.
  Plik `.keystore` przechowuj bezpiecznie i nie dodawaj do repozytorium.
- Lokalnie (Node 22, JDK 21, Android SDK): `cd native && npm run apk`

## Każde wdrożenie
Podbij `APP_VERSION` w `public/index.html` i `VERSION` w `public/sw.js`, potem:
```bash
git commit -am "v1.0.1" && git push
```
Ręcznie, bez GitHuba: `npx wrangler pages deploy`
