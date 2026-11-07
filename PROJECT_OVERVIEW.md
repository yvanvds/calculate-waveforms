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
Flutter met Dart, gekozen voor de interactieve bediening, golfvisualisaties en de mogelijkheid om later meerdere platformen te ondersteunen. Berekeningen, visualisatie en geluid gebruiken dezelfde golfgegevens, zodat het zichtbare en hoorbare resultaat overeenkomen. De concrete audiobouwsteen wordt bij de uitvoering gekozen.

## Golfgegevens

Sinusgolven gebruiken 48.000 samples per seconde, amplitude 1 en 96.000 samples per golf: precies twee seconden. De sampletijd is `index / 48000`; het eindpunt op twee seconden wordt niet dubbel opgeslagen. Grafieken lezen deze gegevens rechtstreeks. Latere audio en bewerkingen gebruiken dezelfde tijdsbasis. Het invoerbereik is 1 tot en met 20.000 Hz, onder de Nyquistgrens van 24.000 Hz. Nieuwe golven starten op 440 Hz. Naast het volledige overzicht toont een detailgrafiek de eerste drie oscillaties (maximaal twee seconden). Per beeldpunt bewaart het overzicht de kleinste en grootste samplewaarde om snelle oscillaties niet weg te laten vallen.

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
