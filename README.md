# PROGETTO_AERODINAMICA
## Scopo del progetto
**Prima parte** : utilizzare XFoil per validare l’implementazione del metodo di Hess-Smith, confrontando distribuzione di Cp e valori di CL e CM per il profilo NACA0012 ad angolo di attacco 2 gradi (caso ideale). Per il profilo AH_79_100_C e per il NACA0012, stimare l’angolo di incidenza di progetto e studiare le condizioni di separazione e di transizione.

**Seconda parte**: utilizzare l'implementazione del metodo di Weissenger per descrivere le caratteristiche aerodinamiche dell'ala del Cessna 172 Skyhawk e dell'ala del Lockheed U-2, confrontando

 1) la pendenza della curva $c_{l/\alpha}$ e l'attrito indotto e la distribuzione di circolazione con quella per una distribuzione di portanza ellittica 
 2) le polari. 

Aggiungere i piani di coda per il Cessna 172 Skyhawk e per Lockheed U-2, e descrivere i loro effetti. Dove LochLockheed U-2 è stato scelto tenendo conto delle limitazioni del metodo di Weissinger. 

## Organizzazione
Il progetto analogamente alla consegna prevede la suddivisione in due parti: `Prima parte` `Seconda parte`. In entrambi i casi gli script matlab e  bash fondamentali sono direttamente inseriti nelle cartelle stesse, oltre a questo è stata operata un'ulteriore suddivisione:

- `Funzioni_matlab`: contiene tutte le funzioni implementate che vengono richiamate dagli script.
  
-  `Grafici`: racchiude tutti i grafici significativi relativi alla rispetitva parte del progetto.
  
- `dati` (presente solo in `Prima parte`): racchiude tutti i file .dat di input oltre ad essere la cartella di appoggio di tutti i file .dat temporanei creati dai file bash `bash_profilo_sottile.sh` e `bash_new.sh`. `Transizione_AH79_100C*` e `transizione_NACA0012*` contengono tutti i file dati con le informazioni relative a transizione e separazione calcolate da xfoil (tramite il file bash `transizione.sh`) al variare del numero di Reynolds e dell'angolo d'incidenza. 

- `relazione laboratorio` (presente solo in `Prima parte`): contiene tutti i file relativi alla relazione scritta su overleaf.

## Utilizzo

### Prima parte

- `Hess_smith.m` è uno script che era in parte fornito già implementato ed è stato completato con l'aggiunta del calcolo dei coefficienti aerodinamici richiesti: coefficiente di pressione, coefficiente di portanza, coefficiente di momento (calcolato nel punto al 25% della corda). 

- `confronto_NACA_0012.m` per il profilo NACA0012 implementa il confronto dei valori dei coefficienti aerodinamici ottenuti mediante l'utilizzo del metodo di Hess Smith e i valori calcolati da xfoil (in entrambi i casi considerando l'angolo di attaco di 2 gradi) al fine di  validare lo script `Hess_Smith.m`.

- `Calcolo_Theodorsen.m` calcola l'angolo di Theodorsen dei profili NACA0012 e AH_79_100_C utilizzando due metodi. Richiamando la funzione `theodorsen.m` l'angolo di progetto è calcolato utilizzando la teoria dei profili sottili mentre tramite la funzione `tehodorsen_cp.m` viene calcolato secondo delle considerazioni sul coefficiente di pressione calcolato tramite xfoil. 

- `grafici_trans_sep.m` genera dei grafici utili per il confronto di transizione e separazione sui profilo AH_79_100_C e NACA0012 al variare del numero di Reynolds e dell'angolo di incidenza.

- `test_Npannelli.m` verifica l'accuratezza del metodo di Hess Smith all'aumentare del numero di pannelli confrontando i risultati con quelli ottenuti da xfoil.

- `test_calcolo_linea_media.m` implementa un utile confronto grafico che permette di verificare l'accuratezza del calcolo della linea media da noi implementato in `calcolo_linea_media.m`.

- `test_theodorsen.m` script ausiliare che calcola l'angolo di theodorsen di alcuni profili NACA mediante le funzioni `theodorsen.m` e `theodorsen_cp.m` e confronta i risultati con quelli noti (vedere la relazione per la fonte). 

- I vari script .sh sono utilizzati dagli stessi script matlab o dal terminale e permettono di utilizzare xfoil iterativamente per estrapolare i dati necessari ad eseguire le varie operazioni. Quando utilizzati in matlab questi file sono già eseguibili, altrimenti, se lanciati da terminale, è necessario scrivere i seguenti comandi al fine di renderli eseguibili
```
chmod +x nomefile.sh
sudo ./nomefile.sh
``` 

### Seconda parte

- `Weissinger.m` funzione matlab che implementa il metodo di Weissinger ed il calcolo dei coefficienti di portanza e resistenza indotta sia bidimensionali che totali
- `geometria_Weissinger.m` funzione matlab che discretizza la geometria in pannelli, determina le coordinate dei punti di controllo e degli estremi dei vorici.
- `Grafici_Weissinger.m` utilizzando la funzione `Weissinger.m` costruisce i grafici fondamentali per il confronto dei parametri calcolati e li salva nella cartella `./Grafici`


## Risultati

| output | script |
|--------|--------|
| $C_p$ | `Hess_smith.m`|
| $C_l$ | `Hess_smith.m`|
| $C_m$ |`Hess_smith.m`|
|$\alpha_{th}$ |`Calcolo_Theodorsen.m`|
|Transizione e separazione | `transizione.sh` e `grafici_trans_sep.m`|
|Curva $C_{L/\alpha }$| `Grafici_Weissinger.m`|
|Attrito indotto | `Grafici_Weissinger.m`|
|Distribuzione di circolazione | `Grafici_Weissinger.m`|
|Polari | `Grafici_Weissinger.m`|
 
Il report del progetto è visualizzabile al seguente indirizzo: [Report progetto .pdf](https://github.com/MasterAle08/PROGETTO_AERODINAMICA/blob/main/Prima%20parte/relazione%20laboratorio/PROGETTO_AERODINAMICA.pdf)