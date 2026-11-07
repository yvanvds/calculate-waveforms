# Rekenen met waveforms

## Doel
Leerlingen ontdekken via beeld en geluid hoe golven zich tot elkaar verhouden en hoe eenvoudige golven complexe geluiden kunnen modelleren. De app sluit aan bij de cursus fysica.

## Doelgroep
Leerlingen van het zesde middelbaar.

## Eerste versie
- Start met een sinusgolf met een vrij instelbare frequentie.
- Elke golfvorm duurt precies twee seconden en kan visueel bekeken en beluisterd worden.
- Onder de golfvormen staat een balk met opties om een sinusgolf of envelope toe te voegen, een bestaande golf met een kommagetal te vermenigvuldigen en twee golven op te tellen.
- Elke golf en envelope heeft een eigen, herkenbaar ID.
- Elke bewerking levert een nieuwe golf met een eigen ID op; de oorspronkelijke golven blijven beschikbaar.
- Toon de relatie tussen de golven, bijvoorbeeld `W3 = W1 + W2` of `W4 = W1 × 0,5`.
- Envelopes bepalen het volumeverloop: geleidelijk aanzwellen, geleidelijk uitdoven en ADSR (aanzet, terugval, aanhouden en loslaten).
- Een envelope toepassen levert een nieuwe golf op, bijvoorbeeld `W5 = W1 × E1`.
- Als een bron of instelling verandert, worden alle afgeleide golven meteen opnieuw berekend en getoond. Bij opnieuw afspelen hoor je het bijgewerkte resultaat.

## Nog niet
- Andere brongolfvormen dan sinusgolven.
- Downloaden of exporteren van gemaakte golven; dit is een gewenste latere uitbreiding.
- Projecten bewaren, accounts of gegevens tussen toestellen delen.
- Installeerbare desktop- of mobiele apps.

## Platform
Eerst een website die leerlingen via een link openen, zonder installatie of account. Flutter houdt de mogelijkheid open om later ook een installeerbare app te maken.

## Frameworks en bouwstenen
Flutter met Dart, gekozen voor de interactieve bediening, golfvisualisaties en de mogelijkheid om later meerdere platformen te ondersteunen. Berekeningen, visualisatie en geluid gebruiken dezelfde golfgegevens, zodat het zichtbare en hoorbare resultaat overeenkomen. Audio gebruikt de Web Audio API via `package:web`.

## Golfgegevens

Sinusgolven gebruiken 48.000 samples per seconde, amplitude 1 en 96.000 samples per golf: precies twee seconden. De sampletijd is `index / 48000`; het eindpunt op twee seconden wordt niet dubbel opgeslagen. Grafieken lezen deze gegevens rechtstreeks. Latere audio en bewerkingen gebruiken dezelfde tijdsbasis. Het invoerbereik is 1 tot en met 20.000 Hz, onder de Nyquistgrens van 24.000 Hz. Nieuwe golven starten op 440 Hz. Naast het volledige overzicht toont een detailgrafiek de eerste drie oscillaties (maximaal twee seconden). Per beeldpunt bewaart het overzicht de kleinste en grootste samplewaarde om snelle oscillaties niet weg te laten vallen.

## Bewerkingen

Vermenigvuldigen en optellen bewaren verwijzingen naar hun bronnen. Iedere wijziging herberekent de afgeleide golven in aanmaakvolgorde met dezelfde 96.000 tijdstippen. Bronkeuzes tonen eerdere golven; zo kan een resultaat opnieuw als bron dienen zonder kringverwijzingen. Factoren aanvaarden komma's en punten, nul en negatieve waarden. Ongeldige of te grote resultaten geven feedback en behouden de laatste geldige berekening. Alle grafieken delen een amplitudeschaal die minstens −1 tot +1 beslaat en uitbreidt tot de grootste amplitude in de werkruimte. Daardoor blijven verschillen tussen golven zichtbaar, ook boven amplitude 1.

## Envelopes

Envelopes krijgen eigen ID's E1, E2 enzovoort. Lineair aanzwellen gaat van 0 naar 1, uitdoven van 1 naar 0 over twee seconden. ADSR begint met 0,2 s aanzet, 0,3 s terugval, niveau 0,7 en 0,5 s loslaten: daardoor blijft 1 s aanhouden over. Dit geeft een herkenbare aanzet met ruimte om alle fasen te onderzoeken. Nulduurfasen springen meteen naar de volgende fase. De grafiek toont ook het eindpunt; audiosamples blijven de gedeelde tijdsbasis [0, 2) gebruiken. Toepassen bewaart verwijzingen naar golf en envelope; wijzigingen werken door naar volgende bewerkingen.

## Audio

Flutter web gebruikt `package:web` met de ingebouwde Web Audio API (`AudioBufferSourceNode`). Die speelt een buffer met onze eigen samples af en stopt aan het einde; er wordt geen aparte oscillator gebruikt. Zie de [Web Audio-documentatie](https://developer.mozilla.org/en-US/docs/Web/API/AudioBufferSourceNode). De buffer bevat 96.000 samples op 48.000 Hz en duurt dus twee seconden. Alleen een druk op Afspelen maakt of hervat de audiocontext. Stoppen en een andere golf starten onderbreken de vorige bron. De status volgt het einde van de browserbron.

Iedere afspeelactie kopieert de actuele grafiekgegevens naar een mono Float32-buffer. Alleen in die kopie geldt een vaste versterking van 0,2 en harde begrenzing op −0,9 en +0,9. Er is geen normalisatie per golf; amplitudeverschillen blijven hoorbaar tot de begrenzing. De berekende golf en grafiek blijven ongewijzigd. Dit garandeert geen veilig toestelvolume: dat hangt ook van de luidsprekers, hoofdtelefoon en volumestand af.

De geautomatiseerde Chromium-proef gebruikt `--web-browser-flag=--autoplay-policy=no-user-gesture-required`: een Flutter-testtap telt voor Chromium niet als vertrouwde gebruikersklik. Dit is uitsluitend een testinstelling; de app start audio alleen vanuit de afspeelknop. De proef controleert de echte browserroute en het natuurlijke einde, maar beluistert het geluid niet.

## Opslag
De eerste versie bewaart niets blijvend. Na opnieuw laden begint de gebruiker opnieuw. De app verwerkt geen namen, punten of andere leerlinggegevens. Geheimen en echte leerlinggegevens horen niet in code, voorbeelden of de publieke repository.

## Vormgeving
Gebruikt het design system in `design-system/`. Flutter neemt kleuren, lettertypes en andere stijlwaarden over uit `design-system/tokens.json`; de componentvoorbeelden dienen als visuele leidraad.

## Testen
- Sinusgolven hebben de ingestelde frequentie en duren precies twee seconden.
- Vermenigvuldigen en optellen leveren wiskundig correcte golfgegevens op.
- Envelopes volgen het gekozen volumeverloop en worden correct toegepast.
- ID's zijn uniek en bewerkingen verwijzen naar de juiste bronnen.
- Wijzigingen werken door naar alle afhankelijke golven, ook bij meerdere opeenvolgende bewerkingen.
- Grafieken en audio komen uit dezelfde berekende golfgegevens; geluidsweergave beschermt tegen onveilig hoge uitgangsniveaus zonder de rekenresultaten te veranderen.
- Alle zichtbare handelingen worden ook in de echte webapp gecontroleerd, waaronder toevoegen, wijzigen, combineren en afspelen.

## Publicatie
Publicatie als Flutter-webapp op GitHub Pages. Elke merge naar de hoofdbranch publiceert de site automatisch via een nog in te richten workflow.

## Beschikbare tools
Git, GitHub CLI en Flutter zijn aanwezig. GitHub is aangemeld en de repository gebruikt het anonieme GitHub-mailadres voor commits. De Flutter-webbasis bestaat; de gecontroleerde ontwikkel-, test- en buildcommando's staan in AGENTS.md. Figtree wordt samen met de app geleverd, zodat het lettertype geen externe verbinding nodig heeft.
