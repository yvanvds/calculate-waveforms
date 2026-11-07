# Werken met Codex

Dit is een template waarmee collega's zonder programmeerervaring apps maken. Praat in de taal van de gebruiker, kort en zonder jargon. Leg technische keuzes eenvoudig uit en geef een aanbeveling. Stel bij het verkennen van een project één vraag tegelijk.

## Projectcontext

- Lees `PROJECT_OVERVIEW.md` als het bestaat. Daar staan doel, eerste versie, gekozen frameworks, opslag en publicatie.
- Gebruik het design system in `design-system/README.md`, tenzij het projectoverzicht iets anders kiest.
- De Codex-skills zijn zelfstandige bestanden in `.agents/skills/`. De Claude-werkwijze in `.claude/` blijft apart: pas die alleen aan als de gebruiker dat vraagt.
- Lees en volg `.agents/commandos.md` bij het uitvoeren van commando's, ook als subagent.

## Werkwijze

- `$setup` bespreekt het project en schrijft `PROJECT_OVERVIEW.md`, zonder applicatiecode.
- `$bootstrap-github` zet GitHub klaar. Werk daarna dit bestand bij met de gekozen bouwstenen en concrete build- en testcommando's, met behoud van deze afspraken. Een aparte `/init` is in de Codex-route niet nodig.
- `$create-issues` maakt concrete GitHub-taken. Applicatiewijzigingen verlopen normaal via een issue en `$work-issue` of `$work-issues`.
- `$work-issues` gebruikt voor elk issue een nieuwe subagent met een eigen context, zonder de conversatiegeschiedenis te kopiëren. Geef de werkmap, skillpaden, branch en alleen noodzakelijke eerdere resultaten mee. Werk na elkaar in dezelfde checkout. De hoofdagent coördineert en ontvangt korte resultaten. Dit is expliciete toestemming voor de in die skill beschreven delegatie.
- Maak nieuwe branches met `codex/` als voorvoegsel. Commit alleen bestanden die bij het werk horen. Behoud bestaande wijzigingen van de gebruiker.
- Een opdracht om issues uit te werken omvat de commits, push, pull request, controles, merge na geslaagde controles en cleanup uit de skill. Een opdracht om alleen te bespreken of issues te maken omvat die stappen niet.
- `$discuss` is uitsluitend overleg: niets wijzigen tot de gebruiker duidelijk tot actie wil overgaan.

## Kwaliteit en gegevens

- Gebruik de gekozen frameworks en schrijf relevante tests voor gewijzigde werking. Test zichtbare handelingen ook met de echte app, volgens de issue-skill.
- Rapporteer alleen echt uitgevoerde controles. Merge nooit met falende controles of onopgeloste conflicten.
- Bewaar geen geheimen, wachtwoorden of echte leerlinggegevens in code, issues of voorbeeldbestanden.
- Voer nooit force-pushes, `git reset --hard`, `git clean` of het verwijderen van de repository uit, ook niet via een andere argumentvolgorde of tool.

## Toestemmingen

De projectinstellingen staan in `.codex/config.toml`; uitleg en beperkingen in `docs/CODEX.md`. Organisatiebeleid en de actieve sessie kunnen strenger zijn. Wijzig zelf geen beveiligingsinstellingen of regels om een blokkade te omzeilen. Meld een geweigerde noodzakelijke handeling en de concrete reden.

## Projectspecifieke aanvullingen

### Doel en eerste versie

- Bouw een interactieve fysica-app voor leerlingen van het zesde middelbaar, volgens `PROJECT_OVERVIEW.md`.
- Begin met sinusgolven met instelbare frequentie. Elke golf duurt precies twee seconden en is zichtbaar en beluisterbaar.
- Geef elke golf en envelope een uniek, herkenbaar ID. Toevoegen, vermenigvuldigen met een kommagetal, optellen en een envelope toepassen leveren nieuwe golven op; behoud de bronnen en toon de gebruikte formule.
- Ondersteun aanzwellen, uitdoven en ADSR als envelopes. Wijzigingen aan bronnen of instellingen werken meteen door naar alle afgeleide golven.
- Bewaar in de eerste versie niets blijvend. Downloads, accounts, andere brongolfvormen en installeerbare apps vallen buiten de eerste versie.

### Bouwstenen en vormgeving

- Gebruik Flutter met Dart en richt de eerste versie op de browser.
- Gebruik dezelfde berekende golfgegevens voor grafieken en audio. Houd berekeningen los van de bediening, zodat de wiskunde afzonderlijk te testen is.
- Kies de concrete audiobouwsteen tijdens het bijbehorende issue. Beperk het uitgangsniveau bij het afspelen zonder de rekenresultaten te veranderen.
- Neem stijlwaarden over uit `design-system/tokens.json` en gebruik de componentvoorbeelden als visuele leidraad voor Flutter. Lees ook `design-system/README.md`.
- Publiceer de webapp op GitHub Pages; richt via een issue automatische publicatie na een merge naar de hoofdbranch in.

### Ontwikkelen, testen en bouwen

- De Flutter-webbasis gebruikt Flutter 3.47.9 en Dart 3.13.7. Installeer afhankelijkheden met `flutter pub get`.
- Starten: `flutter run -d web-server --web-port=8080 --no-web-resources-cdn`, daarna openen op `http://localhost:8080`. Het starten van deze server is gecontroleerd.
- Opmaak: `dart format lib test integration_test test_driver`. Codecontrole: `flutter analyze`. Werking: `flutter test`.
- Webbuild: `flutter build web --base-href /calculate-waveforms/ --no-web-resources-cdn`. Het basispad voor deze projectsite op GitHub Pages is `/calculate-waveforms/`.
- Publicatie: `.github/workflows/checks.yml` controleert pull requests en pushes naar `main`. Alleen na geslaagde controles op `main` wordt `build/web` via de officiële Pages-acties gepubliceerd. Pages is via de GitHub-API ingesteld op `build_type: workflow`, met HTTPS, voor `https://yvanvds.github.io/calculate-waveforms/`.
- Na de eerste merge moet de publieke proef nog gebeuren: geslaagde deployment controleren, startpagina en lokaal meegeleverd Figtree-lettertype in de echte browser bekijken, vernieuwen, en `curl -sI https://yvanvds.github.io/calculate-waveforms/` uitvoeren. Leg het resultaat vast zodra die publicatie bestaat.
- De browserproef staat in `integration_test/start_page_test.dart`, met de driver in `test_driver/integration_test.dart`. Gebruik een passende ChromeDriver en Chromium voor deze test.
- Browserproef: start `chromedriver --port=4445 --disable-build-check` voor de lokaal beschikbare ChromeDriver 156 met Chromium 158. Voer daarna uit: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/start_page_test.dart -d web-server --headless --driver-port=4445 --chrome-binary=/home/phi/.cache/ms-playwright/chromium-1254/chrome-linux64/chrome --no-web-resources-cdn --release --timeout=60`. Dit voerde de startpagina echt in Chromium uit en slaagde. Op CI gebruikt de workflow bij elkaar passende Chrome en ChromeDriver, op standaardpoort 4444.
- Git, GitHub CLI en Flutter zijn bij de setup gecontroleerd. `flutter doctor` kon Chrome toen niet vinden; controleer vóór de browserproeven welke geschikte browser beschikbaar is en los een ontbrekende browser op.
- Test de frequentie en duur van sinusgolven, correcte sommen en vermenigvuldigingen, het verloop en toepassen van envelopes, unieke ID's en het doorwerken van wijzigingen door meerdere bewerkingen.
- Controleer dat grafieken en audio dezelfde golfgegevens gebruiken en dat de geluidsweergave precies twee seconden duurt.
- Controleer toevoegen, wijzigen, combineren en afspelen ook in de echte webapp. Rapporteer afzonderlijk welke automatische en browsercontroles daadwerkelijk zijn uitgevoerd.
