---
name: setup
description: Maakt samen met de gebruiker duidelijk wat dit project wordt. Bespreekt het doel, de eerste versie, het platform, de frameworks en de opslag, kijkt na welke tools ontbreken en schrijft PROJECT_OVERVIEW.md. Gebruik dit als de gebruiker /setup uitvoert.
disable-model-invocation: true
---

# Het project duidelijk maken

Als je een AI gewoon om een app vraagt, kiest die zelf maar wat, en meestal wordt dat één webpagina zonder structuur, frameworks of testen. Deze skill voorkomt dat: je maakt samen de keuzes die een ervaren ontwikkelaar eerst zou maken. Het resultaat is `PROJECT_OVERVIEW.md`.

De gebruiker is meestal een leerkracht zonder programmeerervaring, en heeft hier ongeveer een kwartier voor.

## Hoe je dit gesprek voert

- Praat in de taal van de gebruiker, kort en zonder jargon. Een technisch woord leg je in één korte zin uit.
- Stel **één vraag tegelijk**, en hooguit een tiental in totaal. Wat al duidelijk is, vraag je niet opnieuw.
- Weet de gebruiker het niet, doe dan een voorstel met één zin uitleg en ga verder. "Dat weet ik niet" is een goed antwoord.
- Geef bij technische keuzes altijd jouw aanbeveling. De gebruiker hoeft alleen ja te zeggen, of te zeggen dat het anders moet.
- **Je schrijft geen applicatiecode.** Dat gebeurt later via issues.
- Volg `.claude/rules/commandos.md`: één eenvoudig commando per keer. Kijk de tools dus een voor een na.

Bestaat `PROJECT_OVERVIEW.md` al, lees die dan eerst en vraag alleen wat nog ontbreekt of wat er verandert.

## Stap 1: het doel

Vraag wat de gebruiker wil maken, voor wie, en welk probleem het oplost. Heeft de gebruiker nog geen idee, vertrek dan van een concrete situatie: wat kost nu veel tijd in de les of bij het voorbereiden, of wat begrijpen leerlingen moeilijk?

## Stap 2: de eerste versie

Vraag wat de eerste versie zeker moet kunnen. Hou die klein: het kleinste dat al nuttig is. Spreek ook af wat er bewust **nog niet** in komt, want dat houdt het project beheersbaar.

## Stap 3: gegevens en opslag

Vraag eerst of de app iets moet onthouden. Zo ja: wat, en moet dat op een andere computer ook beschikbaar zijn?

| Manier | Goed voor | Beperking |
|---|---|---|
| Niets bewaren | Een visualisatie, een oefening in één les | Alles is weg als je de pagina sluit |
| Browsergeheugen | Voorkeuren, voortgang op één toestel | Niet op een andere pc of in een andere browser, en weg als het geheugen gewist wordt |
| Bestand downloaden en uploaden | Werk dat je wil meenemen, zonder account | De gebruiker moet er zelf aan denken |
| Gegevens in de URL | Een kleine instelling delen via een link | Alleen voor heel weinig gegevens |
| Bestanden op de eigen computer | Een persoonlijke app, veel gegevens | Vraagt meestal een lokale app in plaats van een website |
| Backend (bijvoorbeeld Firebase) | Aanmelden, gegevens delen tussen gebruikers | Vraagt een account bij een externe dienst, en soms een kredietkaart |

Raad de eenvoudigste manier aan die volstaat.

**Leerlinggegevens:** vraag altijd of er namen, punten of andere gegevens over leerlingen in voorkomen. Zo ja, zeg dan duidelijk dat die gegevens niet in een publieke repo of op een publieke site horen, ook niet als voorbeeld. Kies een manier waarbij ze op de eigen computer blijven, tenzij de school hiervoor een afgesproken oplossing heeft. Vermeld dit in het overview.

## Stap 4: platform en frameworks

Bepaal eerst waar de app moet werken, en stel dan een framework voor. Een framework is code die anderen al geschreven hebben, en die al antwoorden geeft op vragen zoals hoe knoppen eruitzien of hoe onderdelen samenwerken. Zonder framework moet de AI alles zelf bedenken. Stel dus nooit voor om zonder framework te beginnen.

| Situatie | Aanbeveling |
|---|---|
| Website die je gemakkelijk wil delen, zoals uitleg of een interactieve oefening | **Astro**: statische website, gratis te publiceren op GitHub Pages |
| Presentatie, eventueel met interactieve slides | **Slidev** |
| Mogelijk ook een Windows-, Mac- of Android-app, of het is nog onduidelijk | **Flutter**: dezelfde code werkt op meerdere platformen, dus de keuze blijft flexibel |
| Persoonlijke tool, werkt zonder internet, bewaart gegevens lokaal | **Flutter** als lokale app |

Andere opties stel je alleen voor als ze echt beter passen:

- **TeachBooks:** een wetenschappelijke cursus als website.
- **React:** een website die ook een backend nodig heeft.
- **.NET:** een Windows-app die sterk moet samenwerken met Windows of andere programma's.

Vraag ook hoe de app later bij de gebruikers moet raken. Een website kan op GitHub Pages. Een lokale app kan als release op GitHub, maar Windows waarschuwt bij het starten van onbekende software. Dat is overkomelijk als je het even voordoet, maar minder de moeite voor een app die je maar in één les gebruikt.

Kies je een website op GitHub Pages, zeg dan in één zin dat elke wijziging die in de hoofdbranch komt, daarna vanzelf online gaat. Je moet er dus niet aan denken om te publiceren, en je site is altijd gelijk aan je echte app.

Wijzig je voorstel gerust als iets anders beter past, en leg kort uit waarom.

## Stap 5: testen

Leg in twee zinnen uit dat testen kleine controles zijn die ervoor zorgen dat alles blijft werken zoals bedoeld, ook na latere aanpassingen, en dat de gebruiker ze niet zelf moet schrijven. Vraag daarna wat er zeker altijd moet blijven werken, en noteer dat in de woorden van de gebruiker.

## Stap 6: vormgeving

Vraag hier niets. Vermeld dat dit project een design system bevat in `design-system/`, dat de AI standaard gebruikt, en dat de gebruiker later altijd aan de AI kan vragen om een ander design te ontwerpen en het huidige te vervangen.

Kies je Flutter, zeg dan niets extra: de kleuren en lettertypes worden overgenomen uit `design-system/tokens.json`.

## Stap 7: tools nakijken

Kijk na wat er op deze computer ontbreekt voor de gekozen richting:

- Altijd: `git` en `gh`.
- Astro, Slidev, TeachBooks of React: Node.js LTS. TeachBooks vraagt ook Python.
- Flutter: de Flutter SDK. Gebruik daarna `flutter doctor` om te zien wat er nog nodig is voor het gekozen platform.

Zeg wat er ontbreekt en stel voor om het te installeren. Na akkoord installeer je het zelf:

- **Windows:** via `winget`, bijvoorbeeld `winget install --id Git.Git -e`, `winget install --id GitHub.cli -e` of `winget install --id OpenJS.NodeJS.LTS -e`. Is de naam niet zeker, zoek die dan op met `winget search`.
- **Mac:** via `brew` als dat beschikbaar is.
- **Linux:** via de pakketbeheerder van het systeem.

Zeg het vooraf als een installatie lang duurt. Vindt het systeem een tool na installatie niet meteen, dan moet de terminal meestal opnieuw gestart worden. Leg dan uit hoe de gebruiker Claude Code opnieuw opent in deze map, en dat je daarna verder kan met `/setup`.

Controleer daarna GitHub:

1. `gh auth status`. Is de gebruiker niet aangemeld, vraag dan om `gh auth login` zelf uit te voeren door in de prompt `! gh auth login` te typen, en leg uit dat GitHub, HTTPS en aanmelden via de browser de juiste keuzes zijn.
2. Laat git het account van `gh` gebruiken: `gh auth setup-git`.
3. Stel de naam en het mailadres in voor deze repo, met het anonieme GitHub-adres, zodat het privé-mailadres van de gebruiker niet in de publieke geschiedenis komt. Vraag eerst `gh api user --jq .login` en daarna `gh api user --jq .id` op, en vul de waarden letterlijk in:
   ```
   git config user.name "<login>"
   ```
   ```
   git config user.email "<id>+<login>@users.noreply.github.com"
   ```

## Stap 8: PROJECT_OVERVIEW.md schrijven

Schrijf `PROJECT_OVERVIEW.md` in de taal van de gebruiker, kort en concreet. Dit document leest elke latere AI-sessie, dus vermeld ook waarom je iets gekozen hebt.

```markdown
# <naam van het project>

## Doel
<wat het doet, en welk probleem het oplost>

## Doelgroep
<wie het gebruikt>

## Eerste versie
- <wat die zeker moet kunnen>

## Nog niet
- <wat bewust later komt>

## Platform
<keuze en waarom>

## Frameworks en bouwstenen
<keuze en waarom>

## Opslag
<keuze en waarom, en wat er niet bewaard mag worden>

## Vormgeving
Gebruikt het design system in `design-system/`.

## Testen
- <wat er altijd moet blijven werken>

## Publicatie
<hoe de app bij de gebruikers raakt. Bij een website op GitHub Pages: elke merge naar de hoofdbranch publiceert de site automatisch via een workflow.>
```

Toon de gebruiker een korte samenvatting en vraag of dit klopt. Pas aan wat nog niet klopt.

Commit en push daarna rechtstreeks naar de hoofdbranch. Dit is geen code, en er zijn nog geen issues om aan te koppelen:

Voer deze drie commando's na elkaar uit:

```
git add PROJECT_OVERVIEW.md
```
```
git commit -m "Projectoverzicht toevoegen"
```
```
git push
```

## Stap 9: afronden

Vertel in één of twee zinnen wat er nu vastligt. Noem daarna de volgende stappen:

```
/bootstrap-github
```
```
/init
```
```
/create-issues Kijk in PROJECT_OVERVIEW.md. Maak issues aan om de eerste versie van deze app te realiseren.
```
