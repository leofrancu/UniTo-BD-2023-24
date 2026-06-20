<div align="center">

# 🍕 Cibora — Food Delivery Database
### Relational database design and implementation for a food delivery platform

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-DDL%20%2B%20DML-336791?style=for-the-badge&logo=databricks&logoColor=white)
![University](https://img.shields.io/badge/UniTO-A.A.%202023%2F2024-8B0000?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)

🌐 [Leggi in Italiano](README.it.md)

<p>
  <a href="https://github.com/leofrancu">GitHub</a> ·
  <a href="https://www.linkedin.com/in/leonardofrancu">LinkedIn</a>
</p>

</div>

---

## Overview

This project was developed for the **Database** laboratory course at the University of Turin. The goal was to design and implement a relational database for **Cibora**, a fictional food delivery platform similar to Deliveroo or Just Eat.

The project covers the full database design pipeline:

```
Requirements Analysis  →  E-R Design  →  E-R Restructuring  →  Relational Schema  →  SQL Implementation
```

---

## Features

- ✅ **Full E-R diagram** — conceptual design with entities, relationships, and cardinalities
- ✅ **Restructured E-R diagram** — optimised for relational mapping (generalisation resolution, redundancy removal)
- ✅ **23-table relational schema** — implemented in PostgreSQL with constraints, foreign keys, and cascades
- ✅ **Complete DML** — realistic sample data covering users, restaurants, riders, orders, reviews, and messages
- ✅ **Business logic via constraints** — CHECK constraints, UNIQUE, DEFAULT, and referential integrity throughout

---

## Domain Description

**Cibora** is a food delivery service managing:

- **Users** — registration, electronic wallet, premium subscriptions, discount codes, and monthly spending rankings
- **Restaurants** — profile, categories, dish menu with ingredients and allergens, Top Partner badge (awarded based on order volume, rating ≥ 4.5★, cancellation rate ≤ 1.5%, complaint rate ≤ 2.5%)
- **Orders** — cart composition, order lifecycle (preparation → delivery → completed/cancelled/complained), cancellation timestamps
- **Riders** — classified by vehicle type (standard bike, e-bike, scooter); scooter riders track remaining battery range; assignment algorithm minimises total distance (rider → restaurant → customer), with e-bike-only constraint for routes over 10 km
- **Reviews & messaging** — post-delivery ratings (1–5 stars + optional comment) for both restaurant and rider; in-order chat between user ↔ restaurant and user ↔ rider
- **Monthly rankings** — fastest riders, most popular dishes, highest-rated restaurants, top-spending customers

---

## Project Structure

```
.
├── E-R Principale.png         # Conceptual E-R diagram
├── E-R Ristrutturato.png      # Restructured E-R diagram (pre-relational mapping)
├── Progetto.sql               # Full SQL: schema (DDL) + sample data (DML)
└── Francu_Giannerini_relazione_progetto.pdf   # Full project report (Italian)
```

---

## Database Schema

The relational schema consists of **23 tables**:

| Table | Description |
|---|---|
| `utente` | Registered users (email PK, wallet balance, premium flag, monthly spending) |
| `mezzoPagamento` | Payment methods linked to users (credit card, PayPal, Satispay) |
| `telefono` | Phone numbers (multi-valued attribute, separate table) |
| `buonoSconto` | Discount codes associated with users |
| `ristorante` | Restaurants (profile, address, shipping cost, rating index, Top Partner data) |
| `categoria` | Restaurant food categories (e.g. fast food, vegetarian) |
| `afferenzaRistorante` | Restaurant ↔ category association |
| `pietanza` | Menu dishes (title + restaurant PK, price, discount, ranking) |
| `ingrediente` | Ingredient catalogue |
| `ricetta` | Dish ↔ ingredient association |
| `allergene` | Allergen catalogue |
| `avvertenze` | Dish ↔ allergen warnings |
| `lista` | Dish lists (e.g. promotions, best sellers, gluten-free) |
| `afferenzaPietanza` | Dish ↔ list association |
| `ordine` | Orders (lifecycle timestamps, delivery address, total cost, tip) |
| `carrello` | Order line items (order ↔ dish ↔ quantity) |
| `reclamo` | Complaints sent by users to restaurants |
| `rider` | Riders (vehicle type, GPS position, status, delivery stats) |
| `consegna` | Delivery records (rider ↔ order, distance, time) |
| `messaggioRider` | Chat messages between user and rider |
| `messaggioRistorante` | Chat messages between user and restaurant |
| `recensioneRider` | Rider reviews (stars + optional comment) |
| `recensioneRistorante` | Restaurant reviews (stars + optional comment) |

---

## Key Design Decisions

**Top Partner logic** — tracked directly on the `ristorante` table via `indiceApprezzamento`, `totaleRecensioni`, `promozione`, and `dataIngresso`. The badge is stored as a `bytea` image field, with entry date recorded when the threshold is first met.

**Rider assignment** — the constraint that only e-bikes are eligible for routes over 10 km is enforced at the application layer; the `consegna` table records `distanzaTotale` to support post-hoc verification and performance tracking.

**Order lifecycle** — modelled via a `status` CHECK constraint (`In Preparazione`, `In Consegna`, `Annullato`, `Concluso`, `Reclamato`) with dedicated timestamp columns (`timestampRider`, `timestampAnnullamento`, `timestampConsegna`) for fine-grained tracking.

**Generalisation resolution** — the rider vehicle type generalisation (bike / e-bike / scooter) was collapsed into a single `rider` table with a `mezzoTrasporto` attribute and a nullable `autonomia` column (km before battery death, only relevant for scooters).

**Referential integrity** — all foreign keys use `ON UPDATE CASCADE ON DELETE CASCADE` where appropriate, with `ON DELETE SET NULL` for optional associations (ingredients, allergens) to preserve recipe/allergen data even if catalogue entries are removed.

---

## Getting Started

### Prerequisites

- PostgreSQL 12 or higher
- `psql` or any PostgreSQL client (pgAdmin, DBeaver, TablePlus, etc.)

### Run the schema and load sample data

```bash
# Create a new database
createdb cibora

# Execute the full SQL file
psql -d cibora -f Progetto.sql
```

Or from inside `psql`:

```sql
\c cibora
\i Progetto.sql
```

### Verify the schema

```sql
-- List all tables
\dt

-- Check sample restaurants
SELECT idRistorante, nome, indiceApprezzamento FROM ristorante;

-- Check order status
SELECT idOrdine, status, costoTotale FROM ordine;
```

---

## Sample Data

The SQL file includes realistic sample data:

- **5 restaurants** across different categories (pizza, pasta, sushi, fast food)
- **6 orders** covering all lifecycle states (completed, cancelled, complained)
- **3 riders** with different vehicle types (bike, e-bike, scooter)
- **11 dishes** with ingredients, allergens, and list memberships
- **Reviews, complaints, and chat messages** for completed orders
- **Monthly ranking positions** pre-populated on users, restaurants, riders, and dishes

---

## Technologies

- **PostgreSQL** — target RDBMS
- **SQL (DDL + DML)** — schema definition and data population
- **E-R modelling** — conceptual and restructured diagrams

---

## Authors

**Leonardo Francu** & **Ciprian Giannerini**
Corso di Laurea in Informatica — Università degli Studi di Torino
A.A. 2023/2024 · Group project (2 members)

[![GitHub](https://img.shields.io/badge/GitHub-leofrancu-181717?style=flat&logo=github)](https://github.com/leofrancu)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-leonardofrancu-0A66C2?style=flat&logo=linkedin)](https://www.linkedin.com/in/leonardofrancu)
