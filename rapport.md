# Rapport Functioneel Paradigma

Naam: Floris Daniël Voskamp

Studentnummer: 2111473

Klas: ITA-CNI-A-F 2025-2026

Docent: Michel Koolwaaij

Vak en semester: ALPRPA01, CNI

Datum: 13 maart 2026

Versie: 1.0

Voor de verwijzingen in de tekst en de literatuurlijst heb ik de APA 7 richtlijnen aangehouden zoals samengevat door Scribbr (Scribbr, z.d.).

## Inhoudsopgave

[1. Inleiding](#1-inleiding)

[2. Onderzoek naar Haskell](#2-onderzoek-naar-haskell)

[3. Beschrijving van de challenge](#3-beschrijving-van-de-challenge)

[4. Implementatie](#4-implementatie)

[4.1 Opbouw van de applicatie](#41-opbouw-van-de-applicatie)

[4.2 Kern van de simulatie](#42-kern-van-de-simulatie)

[4.3 Scenariovergelijking](#43-scenariovergelijking)

[4.4 Monte Carlo stress test](#44-monte-carlo-stress-test)

[4.5 Configuratie en parser](#45-configuratie-en-parser)

[4.6 Totstandkoming met Git](#46-totstandkoming-met-git)

[5. Koppeling aan functionele concepten](#5-koppeling-aan-functionele-concepten)

[6. Reflectie](#6-reflectie)

[7. Conclusie](#7-conclusie)

[8. Gebruik van GenAI](#8-gebruik-van-genai)

[9. Literatuurlijst](#9-literatuurlijst)

## 1. Inleiding

Voor deze opdracht heb ik `BudgetFlow` gebouwd. Dit is een command line applicatie in Haskell waarmee ik een persoonlijk budget over meerdere maanden kan simuleren. De applicatie leest een configuratiebestand in, rekent vaste inkomsten en uitgaven door, vergelijkt scenario's en voert een Monte Carlo stress test uit met variabele uitgaven.

Ik heb bewust voor Haskell gekozen, omdat dit een van de bekendste functionele programmeertalen is en waarschijnlijk ook de taal is die het duidelijkst laat zien wat functioneel programmeren echt betekent. Vergeleken met de andere genoemde opties zoals Clojure, Elixir en Erlang leek Haskell mij ook moeilijker om goed onder de knie te krijgen. Juist dat vond ik interessant. De syntax is veel wiskundiger en academischer dan de talen die ik normaal gebruik, waardoor het echt voelt als iets anders en niet als een kleine variant op een taal die ik al ken. Ook sprak het idee mij aan dat je met relatief weinig code toch veel functionaliteit kunt bouwen.

Volgens de officiële documentatie is Haskell een lazy, puur functionele taal. Daardoor leek het mij een goede keuze om niet alleen een werkende applicatie te maken, maar ook echt te onderzoeken wat het functionele paradigma in de praktijk toevoegt (Haskell.org, z.d.).

Mijn doel was niet om de makkelijkste opdracht te kiezen. Ik wilde juist iets bouwen waarbij functionele keuzes echt zichtbaar zijn in de code. Een budgetsimulator leek mij daarvoor geschikt, omdat je steeds opnieuw op basis van invoer een nieuwe toestand berekent. Dat past goed bij pure functies. Door daarna ook scenariovergelijking en een Monte Carlo analyse toe te voegen, werd het project inhoudelijk sterk genoeg om meer te laten zien dan alleen basis syntax.

## 2. Onderzoek naar Haskell

Tijdens het vooronderzoek viel mij vooral op dat Haskell heel anders denkt dan de talen die ik normaal gebruik. In talen zoals Java of C# werk ik graag met objectgeoriënteerde concepten. Ik denk dan veel na over architectuur, verantwoordelijkheden van klassen en wat de cleanste oplossing is binnen een objectgericht ontwerp. In Haskell is dat veel minder het uitgangspunt. De taal forceert je veel meer om functioneel na te denken over de code die je schrijft. Je kijkt minder naar objecten en meer naar data, typekeuzes en functietransformaties. Dat is voor mij een fundamenteel andere manier van ontwerpen.

Een belangrijk concept binnen Haskell is zuiverheid. Een pure functie geeft voor dezelfde invoer steeds dezelfde uitvoer en veroorzaakt geen bijwerkingen. Daardoor kun je de code beter voorspellen en makkelijker los testen. Dat sloot goed aan op mijn project, omdat een budgetberekening in de kern gewoon een transformatie van data is. De officiële Haskell documentatie benadrukt ook dat die scheiding tussen pure logica en effectvolle code een kernonderdeel van de taal is (Haskell.org, z.d.).

Daarnaast spelen lijstverwerking en higher order functions een grote rol. Functies zoals `map`, `foldl`, `scanl` en `iterate` zitten standaard in de taal en in de basisbibliotheken en worden juist gebruikt om reeksen waarden te verwerken zonder klassieke for loops te schrijven (Hackage, z.d.-a; Hackage, z.d.-b). Voor mijn project was dat belangrijk, omdat een budgetsimulatie in feite een reeks maandstappen is.

Nog een kenmerk dat ik in mijn project echt heb gebruikt, is lazy evaluation. Waarden worden in Haskell pas berekend als dat nodig is. Daardoor kon ik een tijdlijn als een potentieel oneindige lijst modelleren en daarna alleen het aantal maanden nemen dat in de configuratie staat. In andere talen had ik waarschijnlijk meteen een expliciete lus geschreven. Hier voelde het natuurlijker om het als een reeks waarden op te schrijven.

## 3. Beschrijving van de challenge

De challenge die ik zelf had bedacht heet `BudgetFlow: Personal Budget & Scenario Simulator met Monte Carlo stress test`. Het idee is simpel genoeg om snel uit te leggen, maar technisch niet meer simpel zodra je het echt uitwerkt.

De gebruiker levert een TOML configuratie aan met een startsaldo, het aantal maanden, vaste events, regels en optioneel variabele uitgaven. Vervolgens ondersteunt de applicatie drie hoofdacties.

Bij `run` voert de applicatie een normale simulatie uit en toont per maand het eindsaldo. Bij `scenario` wordt een alternatieve situatie doorgerekend, bijvoorbeeld een extra uitgave vanaf maand 2. Bij `stress` voert de applicatie veel runs achter elkaar uit met willekeurige variabele uitgaven, zodat zichtbaar wordt hoe groot het risico op een negatief eindsaldo is.

Ik vind deze challenge sterk genoeg voor deze opdracht, omdat het niet bij invoer en uitvoer blijft. Ik heb een eigen datamodel gemaakt, een parser gebouwd, een simulatie engine geschreven, scenariovergelijking toegevoegd en daarna ook nog statistische uitkomsten berekend. Vooral dat laatste maakte het project voor mij interessanter. De applicatie laat daardoor niet alleen een vast antwoord zien, maar ook hoe gevoelig een budget is als uitgaven in de praktijk schommelen.

## 4. Implementatie

### 4.1 Opbouw van de applicatie

Ik heb de code opgesplitst in meerdere modules. In [`app/BudgetFlow/Types.hs`](app/BudgetFlow/Types.hs) staan de belangrijkste datatypen. In [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs) zit de basis van de simulatie. [`app/BudgetFlow/Rules.hs`](app/BudgetFlow/Rules.hs) controleert waarschuwingen. [`app/BudgetFlow/Scenario.hs`](app/BudgetFlow/Scenario.hs) verwerkt scenario's. [`app/BudgetFlow/MonteCarlo.hs`](app/BudgetFlow/MonteCarlo.hs) bevat de stress test. [`app/BudgetFlow/Config.hs`](app/BudgetFlow/Config.hs) en [`app/BudgetFlow/TOML.hs`](app/BudgetFlow/TOML.hs) lezen de invoerbestanden in. In [`app/Main.hs`](app/Main.hs) wordt de command line afhandeling gedaan en wordt de uitvoer geprint.

Die verdeling werkte voor mij goed, omdat ik zo de pure logica gescheiden hield van IO. Dat maakte het ook makkelijker om de code uit te leggen. Als ik wilde weten waar een berekening plaatsvond, hoefde ik niet eerst door alle console uitvoer heen te zoeken.

### 4.2 Kern van de simulatie

De kern van het project zit in [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs). Daar verwerk ik eerst losse gebeurtenissen op een saldo. Daarna verwerk ik een hele maand door alle gebeurtenissen op te vouwen tot een nieuw bedrag.

Bron: [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs)

```haskell
applyEvent :: Money -> Event -> Money
applyEvent (Cents balance) (Income (Cents amount)) =
    Cents (balance + amount)
applyEvent (Cents balance) (Expense _ (Cents amount)) =
    Cents (balance - amount)

simulateMonth :: Money -> [Event] -> Money
simulateMonth start events = foldl applyEvent start events
```

Dit stukje code laat goed zien waarom een functionele aanpak hier logisch is. Ik verander nergens een globale variabele. Ik geef een beginsaldo en een lijst met events aan de functie en krijg een nieuw saldo terug. Dat is overzichtelijk, omdat ik de hele maandberekening in één functie kan begrijpen.

Daarna bouw ik de tijdlijn van maanden op. In plaats van handmatig met een teller en een lus te werken, maak ik een reeks maandstaten.

Bron: [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs)

```haskell
simulate :: Config -> [MonthState]
simulate config = take (monthsToSimulate config) (timeline (startBalance config) (monthlyEvents config))

timeline :: Money -> [Event] -> [MonthState]
timeline start events = map (uncurry MonthState) (zip [1..] balances)
  where
    balances = drop 1 (map snd (iterate step ((1 :: Integer), start)))
    step (month, balance) = (month + 1, simulateMonth balance events)
```

Dit vond ik zelf een van de sterkste delen van mijn code. De combinatie van `iterate` en `take` past precies bij lazy evaluation. Ik definieer als het ware een doorlopende tijdlijn en pak daarna alleen het deel dat ik nodig heb.

### 4.3 Scenariovergelijking

De scenariomodule in [`app/BudgetFlow/Scenario.hs`](app/BudgetFlow/Scenario.hs) rekent door wat er gebeurt als er vanaf een bepaalde maand extra events worden toegevoegd. In mijn testscenario uit [`scenario.toml`](scenario.toml) komt er vanaf maand 2 elke maand 150 euro extra uitgave bij. Het eindsaldo daalt daardoor van 6600 euro naar 5850 euro.

De relevante code ziet er zo uit:

Bron: [`app/BudgetFlow/Scenario.hs`](app/BudgetFlow/Scenario.hs)

```haskell
eventsForMonth :: Int -> [Event] -> Scenario -> [Event]
eventsForMonth month baseEvents scenario
  | month >= scenarioFrom scenario = baseEvents ++ scenarioEvents scenario
  | otherwise = baseEvents

simulateWithScenario :: Config -> Scenario -> [MonthState]
simulateWithScenario config scenario =
  let n = monthsToSimulate config
      base = monthlyEvents config
      eventsPerMonth = map (\m -> eventsForMonth m base scenario) [1..n]
      saldi = scanl simulateMonth (startBalance config) eventsPerMonth
  in zipWith MonthState [1..n] (drop 1 saldi)
```

Ik heb hier bewust `scanl` gebruikt in plaats van alleen een eindresultaat te berekenen. Voor een vergelijking wil ik namelijk niet alleen weten wat het eindsaldo is, maar juist ook wat er per maand verandert.

### 4.4 Monte Carlo stress test

De Monte Carlo analyse in [`app/BudgetFlow/MonteCarlo.hs`](app/BudgetFlow/MonteCarlo.hs) was voor mij qua functioneel nadenken het lastigste onderdeel. Hier moest ik goed nadenken over hoe ik variabele uitgaven sample, hoe ik meerdere runs reproduceerbaar maak en hoe ik daarna de uitkomsten weer samenvat tot iets bruikbaars. In [`test.toml`](test.toml) staan vijf categorieën met variabele uitgaven. Per run sample ik daarvoor bedragen binnen een bepaald bereik. Daarna voer ik de simulatie opnieuw uit.

Bron: [`app/BudgetFlow/MonteCarlo.hs`](app/BudgetFlow/MonteCarlo.hs)

```haskell
sampleAmount :: Int -> Distribution -> Int
sampleAmount seed (Uniform lo hi) = fst (randomR (lo, hi) (mkStdGen seed))

oneRun :: Config -> Int -> [MonthState]
oneRun config seed =
  let varEvents = sampleEvents seed (variableExpenses config)
      allEvents = monthlyEvents config ++ varEvents
  in take (monthsToSimulate config) (timeline (startBalance config) allEvents)
```

Ik gebruik hier de random bibliotheek uit Haskell voor reproduceerbare sampling via een seed (Hackage, z.d.-c). Dat vond ik een sterk punt van mijn oplossing, omdat ik zo dezelfde analyse opnieuw kan draaien en dezelfde uitkomst terugkrijg zolang de seed gelijk blijft.

De uitkomst van mijn testconfiguratie vond ik inhoudelijk interessant. De normale simulatie ziet er veilig uit, want het saldo stijgt elke maand met 600 euro. De Monte Carlo analyse laat iets anders zien. Bij 100000 runs is de kans op een negatief eindsaldo 82 procent. De mediaan van het eindsaldo komt zelfs uit op ongeveer min 1304,28 euro. Daardoor laat de applicatie niet alleen zien wat er in het ideale geval gebeurt, maar ook wat er gebeurt als echte uitgaven schommelen.

### 4.5 Configuratie en parser

Het schrijven van de parser in [`app/BudgetFlow/TOML.hs`](app/BudgetFlow/TOML.hs) en [`app/BudgetFlow/Config.hs`](app/BudgetFlow/Config.hs) was qua code schrijven veruit het lastigste onderdeel van de hele opdracht. Bij de Monte Carlo analyse zat het moeilijke deel vooral in het functioneel nadenken over de oplossing. Bij de TOML parser liep ik juist echt vast op de vraag hoe ik die parsing in Haskell moest aanpakken. Ik moest tekstregels opdelen, interpreteren, opschonen en daarna omzetten naar mijn eigen datamodel. In talen zoals C# of Java was dit voor mijn gevoel veel sneller gegaan. Juist omdat ik dit lastig vond, wilde ik het alsnog zelf doen. Ik vond het niet interessant om hier een library voor te gebruiken, omdat een eigen parser mij meer uitdaging gaf en mij dwong om beter te begrijpen hoe data manipulatie in Haskell werkt.

Bron: [`app/BudgetFlow/TOML.hs`](app/BudgetFlow/TOML.hs) en [`app/BudgetFlow/Config.hs`](app/BudgetFlow/Config.hs)

```haskell
parseLine :: String -> LineType
parseLine s =
  let t = trim s
  in case () of
       _ | null t                    -> CommentOrEmpty
       _ | head t == '#'             -> CommentOrEmpty
       _ | head t == '[' && last t == ']' -> Section (init (drop 1 t))
       _ | elem '=' t                -> KeyValue (trim (takeWhile (/= '=') t)) (trim (drop 1 (dropWhile (/= '=') t)))
       _                             -> CommentOrEmpty
```

### 4.6 Totstandkoming met Git

Ik heb Git tijdens het hele proces gebruikt. In de commitgeschiedenis is te zien dat het project stap voor stap is gegroeid. Ik ben begonnen met basisfunctionaliteit op laag niveau. Eerst heb ik de kleinste bouwstenen werkend gemaakt, zoals het simuleren van één maand, een beginbalans en één event dat een nieuw saldo oplevert. Daarna heb ik dat uitgebreid naar meerdere events, meerdere maanden en een volledige simulatie. Pas toen de basis stabiel was, heb ik scenariovergelijking, configuratie parsing en de Monte Carlo analyse toegevoegd. Aan het einde heb ik nog de laatste afwerking gedaan, zoals de README, testconfiguratie en scenariofile.

Dat is voor dit verslag relevant, omdat het laat zien dat ik niet in één keer een eindproduct heb neergezet. Ik heb eerst de basis werkend gemaakt en daarna steeds een volgende laag toegevoegd. Die volgorde was voor mij ook praktisch. Als de basissimulatie niet klopte, had het geen zin om al met scenario's of kansberekeningen verder te gaan. Ik heb daarnaast voor een deel van de applicatie unit tests geschreven in [`test/Spec.hs`](test/Spec.hs). Achteraf gezien had ik juist voor de TOML parser nog meer aan tests gehad, maar die heb ik daar niet toegevoegd.

## 5. Koppeling aan functionele concepten

In mijn implementatie zijn de functionele concepten niet alleen theorie, maar direct zichtbaar in de code.

Zuiverheid zie je in functies zoals `applyEvent`, `simulateMonth`, `simulate` en `timeline` uit [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs), en in `simulateWithScenario` uit [`app/BudgetFlow/Scenario.hs`](app/BudgetFlow/Scenario.hs). Deze functies rekenen alleen met invoerwaarden en geven een nieuwe waarde terug. Ze lezen geen bestanden en printen niets. Daardoor kan ik veel makkelijker redeneren over de uitkomst.

Immutability zie je in de manier waarop ik met `MonthState` werk in [`app/BudgetFlow/Types.hs`](app/BudgetFlow/Types.hs) en de manier waarop nieuwe maandstaten worden opgebouwd in [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs) en [`app/BudgetFlow/Scenario.hs`](app/BudgetFlow/Scenario.hs). Ik pas een bestaande maandstatus niet aan, maar leid steeds een nieuwe toestand af uit de vorige. Dat past goed bij een simulatie over tijd, omdat eerdere maanden dan vast blijven staan.

Higher order functions gebruik ik op meerdere plekken. `foldl` in [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs) verwerkt events tot één saldo. `scanl` in [`app/BudgetFlow/Scenario.hs`](app/BudgetFlow/Scenario.hs) bewaart tussenstappen van een scenario. `map` gebruik ik in meerdere modules om maanden en events om te zetten naar nieuwe waarden. Volgens de documentatie van de Haskell basisbibliotheken zijn dat juist de standaard bouwstenen voor dit soort lijstverwerking (Hackage, z.d.-a; Hackage, z.d.-b).

Pattern matching gebruik ik onder andere in `applyEvent` in [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs), in `checkRule` in [`app/BudgetFlow/Rules.hs`](app/BudgetFlow/Rules.hs) en in `sampleAmount` in [`app/BudgetFlow/MonteCarlo.hs`](app/BudgetFlow/MonteCarlo.hs). Daardoor behandel ik verschillende varianten van data direct op een duidelijke manier.

Lazy evaluation gebruik ik in `timeline` in [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs). Ik definieer geen vaste lijst van precies zes maanden, maar een doorlopende lijst waarvan ik later alleen het nodige deel neem. Dat is een concreet voorbeeld van lazy gedrag, niet alleen een begrip uit de theorie.

De scheiding tussen pure logica en IO zie je terug in [`app/Main.hs`](app/Main.hs) tegenover de overige modules in `app/BudgetFlow/`. In `Main` lees ik argumenten in, laad ik configuratiebestanden en print ik uitvoer. De berekeningen zelf staan juist in andere modules. Dat vond ik prettig werken, omdat de kern van de applicatie daardoor rustiger en duidelijker bleef.

Naast de verplichte functionele concepten heb ik ook nog een paar andere functionele of Haskell specifieke technieken toegepast. De eerste is het gebruik van algebraic data types in [`app/BudgetFlow/Types.hs`](app/BudgetFlow/Types.hs), bijvoorbeeld bij `Event`, `Rule`, `Scenario`, `Distribution` en `VariableExpense`. Hierdoor kon ik mijn domein veel explicieter modelleren dan met losse strings en integers. De tweede is declaratieve lijstverwerking met list comprehensions, bijvoorbeeld in `totalIncome` en `totalExpenses` in [`app/BudgetFlow/Core.hs`](app/BudgetFlow/Core.hs), en ook in `overdraftProbability` in [`app/BudgetFlow/MonteCarlo.hs`](app/BudgetFlow/MonteCarlo.hs). Dat staat niet letterlijk als eis in de opdracht, maar past wel duidelijk binnen de functionele manier van werken.

## 6. Reflectie

Dit is het onderdeel waar ik het meest eerlijk over wil zijn, omdat ik hier ook het meeste van heb geleerd.

Toen ik aan deze opdracht begon, dacht ik dat het Monte Carlo gedeelte het langst zou duren om te schrijven. Het nadenkwerk daarachter was ook ingewikkeld, omdat ik niet alleen één simulatie wilde maken, maar een reproduceerbare stress test met meerdere runs en statistische uitkomsten. Toch bleek uiteindelijk niet Monte Carlo, maar de TOML parser het lastigste onderdeel van de hele opdracht.

Voor de parser moest ik veel tekstmanipulatie en interpretatie doen in Haskell, terwijl ik daar vooraf eigenlijk geen goed beeld van had. Ik wist conceptueel wel wat ik wilde bouwen, maar niet hoe ik dat op een nette manier in Haskell moest aanpakken. Daardoor heb ik hier het langst over gedaan. In C# of Java was dit voor mijn gevoel echt veel makkelijker geweest. Juist daarom wilde ik het toch zelf bouwen. Ik vond het niet leuk om hier een bestaande library voor te gebruiken, omdat ik die extra uitdaging juist interessant vond.

De Monte Carlo analyse was wel het leukste onderdeel om te bouwen. Dat deel voelde het meest als een echte simulatie, mede door de willekeurige variatie in de uitgaven en doordat de uitkomsten inhoudelijk iets zeggen over risico. Ik vind het ook sterk dat dezelfde seeds en dezelfde invoer steeds hetzelfde resultaat opleveren. Daardoor kun je scenario's perfect consistent met elkaar vergelijken. Dat maakt de analyse niet alleen interessanter, maar ook betrouwbaarder.

Wat ik sterk vond aan Haskell, is dat de taal mij dwong om eerder en preciezer na te denken. Dat was soms frustrerend, maar meestal wel terecht. Als een type niet klopte, zat er vaak ook echt een denkfout in mijn ontwerp. In die zin voelde Haskell soms streng, maar wel op een nuttige manier.

Ik merkte ook dat mijn voorkeur voor architectuur en cleane oplossingen uit objectgeoriënteerde talen hier minder centraal stond. In Java of C# denk ik snel in classes, lagen en verantwoordelijkheden. In Haskell moest ik dat veel meer loslaten en eerder denken in typen, functies en datastromen. Dat was wennen, maar ik vond het uiteindelijk ook wel verfrissend, omdat het mij uit mijn vaste patroon haalde.

Als ik dit project opnieuw zou doen, zou ik eerder tests toevoegen voor de parser. Ik heb namelijk wel unit tests geschreven voor een deel van de applicatie in [`test/Spec.hs`](test/Spec.hs), maar juist niet voor het onderdeel waar ik het meest mee worstelde. Achteraf is dat eigenlijk zonde, want daar hadden tests mij juist het meeste kunnen helpen.

## 7. Conclusie

Met `BudgetFlow` heb ik een functionele Haskell applicatie gebouwd die een budget over meerdere maanden simuleert, scenario's vergelijkt en met een Monte Carlo analyse laat zien hoe risicovol een budget in de praktijk kan zijn. De opdracht is inhoudelijk sterk genoeg, omdat ik niet alleen een simpel rekenprogramma heb gemaakt, maar een combinatie van datamodellering, parsing, simulatie en kansberekening.

De belangrijkste functionele concepten uit de opdracht heb ik concreet toegepast in mijn code. Zuiverheid, immutability, higher order functions, pattern matching en lazy evaluation zijn niet alleen begrippen uit de theorie gebleven, maar vormen juist de basis van mijn implementatie.

Mijn belangrijkste leerpunt is dat functioneel programmeren vooral sterk wordt wanneer je probleem echt als een reeks datatransformaties te beschrijven is. In dat soort situaties geeft Haskell veel structuur en voorspelbaarheid. Tegelijk merkte ik dat de taal minder vergevingsgezind is als je snel iets praktisch wilt bouwen. Juist die combinatie maakte deze opdracht voor mij leerzaam.

## 8. Gebruik van GenAI

Ik heb GenAI beperkt gebruikt binnen dit project. Ik heb ChatGPT gebruikt voor het bedenken en aanscherpen van de opdracht en voor een deel van het vooronderzoek (OpenAI, 2026). Daarnaast heb ik AI gebruikt voor het herschrijven van zinnen en grammaticale verbetering van dit verslag. Van die losse grammatica en zinsopbouw chats heb ik geen aparte links meer.

Voor de code heb ik GenAI niet gebruikt om de implementatie inhoudelijk voor mij te schrijven. Wel is de README bovenaan expliciet gemarkeerd als automatisch gegenereerd met GitHub Copilot op basis van de afgeronde codebase. Die README staat in [`README.md`](README.md).

De gebruikte ChatGPT conversatie voor het opdrachtidee en vooronderzoek heb ik wel opgenomen in de literatuurlijst, zodat duidelijk blijft waarvoor AI precies is gebruikt.

## 9. Literatuurlijst

Hackage. (z.d.-a). *Prelude*. https://hackage.haskell.org/package/base/docs/Prelude.html

Hackage. (z.d.-b). *Data.List*. https://hackage.haskell.org/package/base/docs/Data-List.html

Hackage. (z.d.-c). *System.Random*. https://hackage.haskell.org/package/random/docs/System-Random.html

Haskell.org. (z.d.). *Documentation*. https://www.haskell.org/documentation/

OpenAI. (2026, 2 februari). *ChatGPT conversatie over BudgetFlow opdrachtidee en vooronderzoek*. https://chatgpt.com/share/69b33ca5-8f78-800d-be14-86284f0b313e

Scribbr. (z.d.). *APA-stijl (7de editie) | Verwijzingen in de tekst & bronvermeldingen*. https://www.scribbr.nl/category/apa-stijl/
