<div align="center">

# 🍕 Cibora — Database Food Delivery
### Progettazione e implementazione di una base di dati relazionale per una piattaforma di food delivery

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-DDL%20%2B%20DML-336791?style=for-the-badge&logo=databricks&logoColor=white)
![University](https://img.shields.io/badge/UniTO-A.A.%202023%2F2024-8B0000?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completato-brightgreen?style=for-the-badge)

🌐 [Read in English](README.md)

<p>
  <a href="https://github.com/leofrancu">GitHub</a> ·
  <a href="https://www.linkedin.com/in/leonardofrancu">LinkedIn</a>
</p>

</div>

---

## Panoramica

Questo progetto è stato sviluppato per il laboratorio del corso di **Basi di Dati** dell'Università degli Studi di Torino. L'obiettivo era progettare e implementare una base di dati relazionale per **Cibora**, una piattaforma di food delivery analoga a Deliveroo o Just Eat.

Il progetto copre l'intera pipeline di progettazione di una base di dati:

```
Analisi dei requisiti  →  Schema E-R  →  Ristrutturazione E-R  →  Schema relazionale  →  Implementazione SQL
```

---

## Funzionalità

- ✅ **Schema E-R completo** — progettazione concettuale con entità, associazioni e cardinalità
- ✅ **Schema E-R ristrutturato** — ottimizzato per la traduzione in schema relazionale (risoluzione delle generalizzazioni, eliminazione delle ridondanze)
- ✅ **Schema relazionale con 23 tabelle** — implementato in PostgreSQL con vincoli, chiavi esterne e cascate
- ✅ **DML completo** — dati di esempio realistici su utenti, ristoranti, rider, ordini, recensioni e messaggi
- ✅ **Logica di business tramite vincoli** — CHECK, UNIQUE, DEFAULT e integrità referenziale su tutto lo schema

---

## Descrizione del dominio

**Cibora** è un servizio di food delivery che gestisce:

- **Utenti** — registrazione, borsellino elettronico, abbonamento premium, codici sconto e classifica mensile per spesa
- **Ristoranti** — profilo, categorie, menu con ingredienti e allergeni, badge Top Partner (assegnato in base al volume di ordini, valutazione ≥ 4.5★, percentuale annullamenti ≤ 1.5%, percentuale reclami ≤ 2.5%)
- **Ordini** — composizione del carrello, ciclo di vita dell'ordine (preparazione → consegna → concluso/annullato/reclamato), timestamp di annullamento
- **Rider** — classificati per tipo di mezzo (bicicletta, bicicletta elettrica, monopattino); i rider con monopattino indicano l'autonomia residua; l'algoritmo di assegnamento minimizza la distanza totale (rider → ristorante → cliente), con vincolo di soli rider con bici elettrica per percorsi superiori a 10 km
- **Recensioni e messaggistica** — valutazioni post-consegna (1–5 stelle + commento facoltativo) per ristorante e rider; chat durante l'ordine tra utente ↔ ristorante e utente ↔ rider
- **Classifiche mensili** — rider più veloci, cibi più popolari, ristoranti con più recensioni positive, clienti con maggiore spesa

---

## Struttura del progetto

```
.
├── E-R Principale.png         # Schema E-R concettuale
├── E-R Ristrutturato.png      # Schema E-R ristrutturato (pre-traduzione relazionale)
├── Progetto.sql               # SQL completo: schema (DDL) + dati di esempio (DML)
└── Francu_Giannerini_relazione_progetto.pdf   # Relazione completa del progetto
```

---

## Schema della base di dati

Lo schema relazionale è composto da **23 tabelle**:

| Tabella | Descrizione |
|---|---|
| `utente` | Utenti registrati (email PK, saldo borsellino, flag premium, spesa mensile) |
| `mezzoPagamento` | Mezzi di pagamento associati agli utenti (carta di credito, PayPal, Satispay) |
| `telefono` | Numeri di telefono (attributo multivalore, tabella separata) |
| `buonoSconto` | Codici sconto associati agli utenti |
| `ristorante` | Ristoranti (profilo, indirizzo, costo spedizione, indice apprezzamento, dati Top Partner) |
| `categoria` | Categorie di cibo dei ristoranti (es. fast food, vegetariano) |
| `afferenzaRistorante` | Associazione ristorante ↔ categoria |
| `pietanza` | Piatti del menu (titolo + ristorante PK, prezzo, sconto, posizione classifica) |
| `ingrediente` | Catalogo degli ingredienti |
| `ricetta` | Associazione pietanza ↔ ingrediente |
| `allergene` | Catalogo degli allergeni |
| `avvertenze` | Avvertenze allergeni per pietanza |
| `lista` | Liste di pietanze (es. promozioni, i più venduti, senza glutine) |
| `afferenzaPietanza` | Associazione pietanza ↔ lista |
| `ordine` | Ordini (timestamp del ciclo di vita, indirizzo consegna, costo totale, mancia) |
| `carrello` | Voci dell'ordine (ordine ↔ pietanza ↔ quantità) |
| `reclamo` | Reclami inviati dagli utenti ai ristoranti |
| `rider` | Rider (tipo mezzo, posizione GPS, stato, statistiche consegne) |
| `consegna` | Record di consegna (rider ↔ ordine, distanza, tempo) |
| `messaggioRider` | Messaggi chat tra utente e rider |
| `messaggioRistorante` | Messaggi chat tra utente e ristorante |
| `recensioneRider` | Recensioni dei rider (stelle + commento facoltativo) |
| `recensioneRistorante` | Recensioni dei ristoranti (stelle + commento facoltativo) |

---

## Scelte progettuali principali

**Logica Top Partner** — tracciata direttamente nella tabella `ristorante` tramite `indiceApprezzamento`, `totaleRecensioni`, `promozione` e `dataIngresso`. Il badge è memorizzato come campo `bytea`, con data di ingresso registrata al raggiungimento della soglia.

**Assegnamento del rider** — il vincolo che solo le bici elettriche siano eleggibili per percorsi superiori a 10 km è gestito a livello applicativo; la tabella `consegna` registra `distanzaTotale` per supportare la verifica a posteriori e il monitoraggio delle prestazioni.

**Ciclo di vita dell'ordine** — modellato tramite un vincolo CHECK su `status` (`In Preparazione`, `In Consegna`, `Annullato`, `Concluso`, `Reclamato`) con colonne timestamp dedicate (`timestampRider`, `timestampAnnullamento`, `timestampConsegna`) per un tracciamento granulare.

**Risoluzione della generalizzazione** — la generalizzazione sul tipo di mezzo del rider (bicicletta / bicicletta elettrica / monopattino) è stata appiattita in un'unica tabella `rider` con attributo `mezzoTrasporto` e colonna nullable `autonomia` (km prima che la batteria si scarichi, rilevante solo per i monopattini).

**Integrità referenziale** — tutte le chiavi esterne usano `ON UPDATE CASCADE ON DELETE CASCADE` dove appropriato, con `ON DELETE SET NULL` per le associazioni opzionali (ingredienti, allergeni), per preservare i dati di ricette e avvertenze anche in caso di rimozione di voci dal catalogo.

---

## Come iniziare

### Prerequisiti

- PostgreSQL 12 o superiore
- `psql` o qualsiasi client PostgreSQL (pgAdmin, DBeaver, TablePlus, ecc.)

### Eseguire lo schema e caricare i dati di esempio

```bash
# Creare un nuovo database
createdb cibora

# Eseguire il file SQL completo
psql -d cibora -f Progetto.sql
```

Oppure dall'interno di `psql`:

```sql
\c cibora
\i Progetto.sql
```

### Verificare lo schema

```sql
-- Elenco di tutte le tabelle
\dt

-- Verifica dei ristoranti di esempio
SELECT idRistorante, nome, indiceApprezzamento FROM ristorante;

-- Verifica dello stato degli ordini
SELECT idOrdine, status, costoTotale FROM ordine;
```

---

## Dati di esempio

Il file SQL include dati di esempio realistici:

- **5 ristoranti** in diverse categorie (pizza, pasta, sushi, fast food)
- **6 ordini** che coprono tutti gli stati del ciclo di vita (concluso, annullato, reclamato)
- **3 rider** con diversi tipi di mezzo (bicicletta, bicicletta elettrica, monopattino)
- **11 pietanze** con ingredienti, allergeni e appartenenza alle liste
- **Recensioni, reclami e messaggi chat** per gli ordini completati
- **Posizioni nelle classifiche mensili** precaricate per utenti, ristoranti, rider e pietanze

---

## Tecnologie utilizzate

- **PostgreSQL** — RDBMS target
- **SQL (DDL + DML)** — definizione dello schema e popolamento dei dati
- **Modellazione E-R** — diagrammi concettuale e ristrutturato

---

## Autori

**Leonardo Cosmin Francu** & **Fabio Giannerini**
Corso di Laurea in Informatica — Università degli Studi di Torino
A.A. 2023/2024 · Progetto di gruppo (2 membri)

[![GitHub](https://img.shields.io/badge/GitHub-leofrancu-181717?style=flat&logo=github)](https://github.com/leofrancu)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-leonardofrancu-0A66C2?style=flat&logo=linkedin)](https://www.linkedin.com/in/leonardofrancu)
