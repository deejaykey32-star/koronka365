# CLAUDE.md – Jezu, ufam Tobie (Koronka i Różaniec)

## Projekt
Aplikacja modlitewna WEB + PWA (+ APK z PWABuilder): Koronka do Miłosierdzia Bożego oraz Różaniec
(części: radosne, światła, bolesne, chwalebne). Autor: DjK. Język interfejsu: polski.

## Zasady techniczne
- Vanilla JS, jeden plik `public/index.html` (CSS i JS inline), bez kroków budowania i bez npm w produkcji.
- Hosting: Cloudflare Pages; wdrożenie przez GitHub Actions (`.github/workflows/deploy.yml`, `wrangler pages deploy public`).
- Klucze localStorage z prefiksem `milosierdzie:`.
- Przy każdej zmianie podbij `APP_VERSION` w `public/index.html` i `VERSION` w `public/sw.js`.
- Nagłówki: `public/_headers`.
- APK: `native/` (Capacitor, tylko w CI) buduje `public/download/milosierdzie.apk` z `public/`; w APK `window.Capacitor`
  jest dostępny (`isNative`), lektor przez wtyczkę `TextToSpeech`, ekran przez `KeepAwake`. Nie commituj `native/android`, `native/www` ani APK.

## Wymagania, których nie wolno złamać
- Obraz Jezusa Miłosiernego (`public/img/jezu-milosierny.webp`) zawsze widoczny w całości (SVG `meet`),
  w pionie i poziomie; tło za obrazem = kolor tła obrazu `--canvas: #1f1718`.
- Różaniec w kształcie serca: 54 paciorki w sercu + medalik w górnym zwężeniu serca.
  Z medalika na środku zwisa w dół łańcuszek: duży, 3 małe, duży paciorek i krzyżyk (wewnątrz serca).
- Promienie z Serca Jezusa (`CONFIG.heart`, w pikselach obrazu), jeden na dziesiątek/tajemnicę:
  białe 1 Chrzest, 2 Bierzmowanie, 3 Eucharystia; czerwone 4 Małżeństwo i Kapłaństwo, 5 Spowiedź i Namaszczenie chorych.
- Tryb automatyczny i ręczny (przyciski, strzałki, przesunięcie palcem, stuknięcie w paciorek), podświetlanie paciorków.
- Lektor (Web Speech API, głos pl-PL), napisy z opcją ukrycia, muzyka medytacyjna (Web Audio, generowana).
- Dwa osobne przyciski: „Pobierz aplikację natywną (APK)” i „Pobierz aplikację PWA”.
- Tooltipy `data-tip` na wszystkich kontrolkach. Mobile-first; układ pionowy i poziomy (media query `orientation`).

## Mapa kodu (`public/index.html`)
Konfiguracja `CONFIG` → teksty modlitw `P`, tajemnice `MYST`, sakramenty `SAC` → geometria serca (`heartXY`, `BEADS`)
→ sekwencje `buildKoronka` / `buildRozaniec` → rysowanie `drawPainting` / `drawRosary` → `render`
→ lektor `speak` → tryb automatyczny `runStep` → muzyka `Music` → instalacja `downloadApk` / `installPwa` → zdarzenia.

## Test lokalny
`npx serve public` lub `python3 -m http.server -d public`, sprawdź 390×844, 844×390 i 1440×900.
