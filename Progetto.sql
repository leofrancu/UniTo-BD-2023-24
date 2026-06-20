drop table if exists utente cascade;
drop table if exists mezzoPagamento cascade;
drop table if exists telefono cascade;
drop table if exists buonoSconto cascade;
drop table if exists ordine cascade;
drop table if exists pietanza cascade;
drop table if exists carrello cascade;
drop table if exists ingrediente cascade;
drop table if exists ricetta cascade;
drop table if exists allergene cascade;
drop table if exists avvertenze cascade;
drop table if exists lista cascade;
drop table if exists afferenzaPietanza cascade;
drop table if exists reclamo cascade;
drop table if exists ristorante cascade;
drop table if exists categoria cascade;
drop table if exists afferenzaRistorante cascade;
drop table if exists rider cascade;
drop table if exists consegna cascade;
drop table if exists messaggioRider cascade;
drop table if exists messaggioRistorante cascade;
drop table if exists recensioneRider cascade;
drop table if exists recensioneRistorante cascade;

create table utente (
	email varchar(50) check (email like '%@%.%') primary key,
	nome varchar(25) not null,
	password varchar(30) not null,
	via varchar(25),
	numeroCivico varchar(10),
	città varchar(25),
	cap char(5),
	saldo decimal(6,2),
	premium varchar(2) check (premium in('Si', 'No')) default 'No',
	spesaMensile decimal(6,2) default 0.00,
	posizioneClassifica smallint unique
);

create table ristorante (
	idRistorante varchar(10) primary key,
	nome varchar(50) not null,
	badge bytea,
	dataIngresso date,
	via varchar(25) not null,
	numeroCivico varchar(10) not null,
	città varchar(25) not null,
	cap char(5) not null,
	descrizione varchar(500),
	costoSpedizione decimal(6,2),
	immagineProfilo bytea, 
	indiceApprezzamento smallint check(indiceApprezzamento between 0 and 100),
	totaleRecensioni smallint default 0, 
	tempoAttesaMedio smallint, 
	promozione smallint default 0,
	posizioneClassifica smallint unique
);

create table mezzoPagamento (
	utente varchar(50) not null,
	numeroMezzo smallint not null, 
	titolare varchar(25),
	numeroCarta char(16),
	dataScadenza date,
	cvv char(3),
	email varchar(50) check (email like '%@%.%'),
	telefono varchar(14),
	primary key(utente, numeroMezzo),
	foreign key(utente) references utente(email) on update cascade on delete cascade
);

create table telefono (
	numero varchar(14) primary key,
	utente varchar(50) not null,
	foreign key(utente) references utente(email) on update cascade on delete cascade
);

create table buonoSconto (
	codice char(12) primary key,
	utente varchar(50) not null,
	foreign key(utente) references utente(email) on update cascade on delete cascade
);

create table ordine (
	idOrdine varchar(10) primary key,
	timestampOrdine timestamp not null,
	status varchar(15) check (status in('In Prepazione', 'In Consegna', 'Annullato', 'Concluso', 'Reclamato')),
	utente varchar(50) not null,
	ristorante varchar(10) not null, 
	via varchar(25) not null,
	numeroCivico varchar(10) not null,
	città varchar(25) not null,
	cap char(5) not null,
	costoTotale decimal(6,2) not null,
	mancia decimal(6,2),
	timestampRider timestamp,
	timestampAnnullamento timestamp,
	timestampConsegna timestamp,
	foreign key (utente) references utente(email) on update cascade on delete cascade,
	foreign key (ristorante) references ristorante(idRistorante) on update cascade on delete cascade
);

create table pietanza (
	titolo varchar(25) not null,
	ristorante varchar(10) not null,
	prezzo decimal(6,2) not null,
	sconto smallint,
	immagine bytea,
	posizioneClassifica smallint unique,
	primary key(titolo, ristorante),
	foreign key(ristorante) references ristorante(idRistorante) on update cascade on delete cascade
);

create table carrello(
	ordine varchar(10) not null,
	titolo varchar(25) not null,
	ristorante varchar(10) not null,
	quantità smallint check(quantità >= 1), 
	primary key(ordine, titolo, ristorante),
	foreign key(ordine) references ordine(idOrdine) on update cascade on delete cascade,
	foreign key(titolo, ristorante) references pietanza(titolo, ristorante) on update cascade on delete set null
);

create table ingrediente (
	nome varchar(25) primary key
);

create table ricetta (
	ingrediente varchar(25) not null,
	titolo varchar(25) not null,
	ristorante varchar(10) not null,
	primary key(ingrediente, titolo, ristorante),
	foreign key(ingrediente) references ingrediente(nome) on delete set null,
	foreign key (titolo, ristorante) references pietanza(titolo, ristorante) on update cascade on delete cascade
);

create table allergene(
	nome varchar(25) primary key
);

create table avvertenze (
	allergene varchar(25) not null,
	titolo varchar(25) not null,
	ristorante varchar(10) not null,
	primary key(allergene, titolo, ristorante),
	foreign key(allergene) references allergene(nome) on delete set null,
	foreign key (titolo, ristorante) references pietanza(titolo, ristorante) on update cascade on delete cascade
);

create table lista(
	nome varchar(25) primary key
);

create table afferenzaPietanza (
	titolo varchar(25) not null,
	ristorante varchar(10) not null,
	lista varchar(25) not null,
	primary key(titolo, ristorante, lista),
	foreign key (titolo, ristorante) references pietanza(titolo, ristorante) on update cascade on delete set null,
	foreign key(lista) references lista(nome) on update cascade on delete cascade
);

create table reclamo (
	ordine varchar(10) primary key,
	utente varchar(50) not null,
	ristorante varchar(10) not null,
	timestampr timestamp not null,
	testo varchar(2500) not null,
	foreign key (ordine) references ordine(idOrdine) on update cascade on delete cascade,
	foreign key (utente) references utente(email) on update cascade on delete cascade,
	foreign key (ristorante) references ristorante(idRistorante) on update cascade on delete cascade
);

create table categoria (
	nome varchar(25) primary key
);

create table afferenzaRistorante (
	ristorante varchar(10) not null,
	categoria varchar(25) not null,
	primary key(ristorante, categoria),
	foreign key(ristorante) references ristorante(idRistorante) on update cascade on delete set null,
	foreign key(categoria) references categoria(nome) on update cascade on delete cascade
);

create table rider (
	codice varchar(10) primary key,
	stato varchar(15) check (stato in('Disponibile', 'Occupato', 'Fuori Servizio')),
	mezzoTrasporto varchar check (mezzoTrasporto in('Bicicletta', 'Bicicletta Elettrica', 'Monopattino')),
	autonomia smallint check (autonomia between 0 and 100),
	gps varchar(25) not null, 
	numeroConsegne smallint check (numeroConsegne >= 0), 
	tempoMedioConsegna smallint,
	posizioneClassifica smallint unique
);

create table consegna (
	ordine varchar(10) not null,
	rider varchar(10) not null,
	distanzaTotale smallint check (distanzaTotale >= 0),
	tempoTotale smallint,
	primary key(rider, ordine),
	foreign key(rider) references rider(codice) on update cascade on delete cascade,
	foreign key(ordine) references ordine(idOrdine) on update cascade on delete cascade
);

create table messaggioRider(
	ordine varchar(10) not null,
	timestampm timestamp not null,
	utente varchar(50) not null,
	ruoloUtente varchar(15) check (ruoloUtente in('Mittente', 'Destinatario')), 
	rider varchar(10) not null,
	ruoloRider varchar(15) check (ruoloRider in('Mittente', 'Destinatario')),
	testo varchar(2500) not null,
	primary key(ordine, timestampm),
	foreign key(ordine) references ordine(idOrdine) on update cascade on delete cascade,
	foreign key(utente) references utente(email) on update cascade on delete cascade,
	foreign key(rider) references rider(codice) on update cascade on delete cascade
);

create table messaggioRistorante(
	ordine varchar(10) not null,
	timestampm timestamp not null,
	utente varchar(50) not null,
	ruoloUtente varchar(15) check (ruoloUtente in('Mittente', 'Destinatario')), 
	ristorante varchar(10) not null,
	ruoloRistorante varchar(15) check (ruoloRistorante in('Mittente', 'Destinatario')),
	testo varchar(2500) not null,
	primary key(ordine, timestampm),
	foreign key(ordine) references ordine(idOrdine) on update cascade on delete cascade,
	foreign key(utente) references utente(email) on update cascade on delete cascade,
	foreign key(ristorante) references ristorante(idRistorante) on update cascade on delete cascade
);

create table recensioneRider (
	ordine varchar(10) not null,
	timestampr timestamp not null,
	utente varchar(50) not null,
	rider varchar(10) not null, 
	stelle smallint not null check (stelle between 1 and 5),
	testo varchar(750), 
	primary key(ordine, timestampr),
	foreign key(ordine) references ordine(idOrdine) on update cascade on delete cascade,
	foreign key(utente) references utente(email) on update cascade on delete cascade,
	foreign key(rider) references rider(codice) on update cascade on delete cascade
);

create table recensioneRistorante (
	ordine varchar(10) not null,
	timestampr timestamp not null,
	utente varchar(50) not null,
	ristorante varchar(10) not null, 
	stelle smallint not null check (stelle between 1 and 5),
	testo varchar(750),  
	primary key(ordine, timestampr),
	foreign key(ordine) references ordine(idOrdine) on update cascade on delete cascade,
	foreign key(utente) references utente(email) on update cascade on delete cascade,
	foreign key(ristorante) references ristorante(idRistorante) on update cascade on delete cascade
);


insert into utente (email, nome, password, via, numeroCivico, città, cap, saldo, premium, spesaMensile, posizioneClassifica) 
values
    ('daphne.mount@yahoo.com', 'Daphne Mount', 'FlowersLover4&£', 'Rodriguez Ridge', '199', 'Routeland', '53972', 87.30, 'Si', 0.00, null),
  	('vlad.rotariu@gmail.com', 'Vlad Rotariu', 'RonaldoBoy2009', 'Via Roma', '10', 'Milano', '20121', 100.50, 'No', 38.00, 2),
  	('maria.verdi@gmail.com', 'Maria Verdi', 'Maria_@Verdi05', 'Via Cavour', '25', 'Cagliari', '09121', 50.25, 'Si', 0.00, null),
	('francesco.bianca@gmail.com', 'Francesco Bianca', 'Elle4Rac1ng02_', 'Corso Galileo Galilei', '72/bis','Brindisi', '72100', 257.50, 'Si', 85.00, 1),
	('carla.rosin@outlook.com', 'Carla Rosin', 'RosinLoca1997!', 'Calle de la Torrecilla', '19', 'Madrid', '54139', 1.10, 'No', 0.00, null),
  	('duncan.atlas@icloud.com', 'Duncan Atlas', 'Kobe4Life', 'College Ave', '2101', 'Philadelphia', '19121', 125.75, 'No', 0.00, null);

insert into mezzoPagamento (utente, numeroMezzo, titolare, numeroCarta, dataScadenza, cvv, email, telefono)
values
  	('vlad.rotariu@gmail.com', 1, 'Vlad Rotariu', '1234567890123456', '2025-12-31', '123', null, null),
  	('vlad.rotariu@gmail.com', 2, null, null, null, null, null, '3331234567'),
	('francesco.bianca@gmail.com', 1, 'Francesco Bianca', '4023562891370871', '2026-07-20', '777', null, null),
	('francesco.bianca@gmail.com', 2, null, null, null, null, 'bianca.francesco02@libero.it', null),
	('francesco.bianca@gmail.com', 3, 'Francesco Bianca', '5298740766397778', '2024-06-21', '639', null, null),
  	('maria.verdi@gmail.com', 1, null, null, null, null, null,'3478901234'),
  	('carla.rosin@outlook.com', 1, 'Samuel Foltrin', '9876543210987654', '2024-08-31', '321', null, null),
  	('maria.verdi@gmail.com', 2, null, null, null, null,'maria.verdi@gmail.com', null),
  	('duncan.atlas@icloud.com', 1, null, null, null, null, 'duncan.atlas@icloud.com', null),
    ('daphne.mount@yahoo.com', 1, null, null, null, null, 'daphne.mount@yahoo.com', null);
  
insert into telefono (numero, utente)
values
  	('+393912345678', 'vlad.rotariu@gmail.com'),
  	('+40755765389', 'vlad.rotariu@gmail.com'),
  	('+393298765432', 'maria.verdi@gmail.com'),
    ('+393492766332', 'francesco.bianca@gmail.com'),
  	('+13645321789', 'duncan.atlas@icloud.com'),
    ('+444879922704', 'daphne.mount@yahoo.com'),
    ('+34643638114', 'carla.rosin@outlook.com');
	
insert into buonoSconto (codice, utente)
values
	('BC71738493CG', 'francesco.bianca@gmail.com'),
	('TR362726284F', 'vlad.rotariu@gmail.com');

insert into ristorante (idRistorante, nome, badge, dataIngresso, via, numeroCivico, città, cap, descrizione, costoSpedizione, immagineProfilo, indiceApprezzamento, totaleRecensioni, tempoAttesaMedio, promozione, posizioneClassifica)
values
  	('RIST001', 'Ristorante Pizzeria La Toscana', null, null, 'Via Roma', '123', 'Firenze', '50123', 'Pizzeria tipica con forno a legna. Offriamo pizze classiche e speciali, con ingredienti freschi e di alta qualità.', 1.00, 'toscana.png', 70, 250, 25, 10, 4),
  	('RIST002', 'Ristorante Trattoria Il Ghiottone', null, null, 'Via Cavour', '45', 'Bologna', '40123', 'Trattoria con cucina casalinga emiliana. Pasta fresca fatta in casa, secondi piatti di carne e verdure, e dolci tipici.', 1.60, 'ghiottone.png', 80, 180, 30, 15, 5),
  	('RIST003', 'McDonalds', 'badge.jpg', '2015-04-05', 'Via Roma', '123', 'Milano', '20121', 'Ristorante fast food famoso in tutto il mondo.', 1.50, 'mc.png', 98, 1500, 15, 0, 1),
    ('RIST004', 'Ristorante Sushi & Sashimi Sakura', 'badge.jpg', '2022-03-08', 'Piazza del Popolo', '20', 'Roma', '00123', 'Ristorante giapponese specializzato in sushi e sashimi. Offriamo un ampia varietà di piatti preparati con pesce fresco di alta qualità.', 2.80, 'sushi.png', 90, 150, 20, 20, 3),
    ('RIST005', 'Shake Shack', null, null, 'Madison Ave', '123', 'New York', '10010', 'Ristorante noto per i suoi hamburger gourmet e milkshake.', 3.00, 'shake.png', 86, 800, 20, 5, 2);

insert into ordine (idOrdine, timestampOrdine, status, utente, ristorante, via, numeroCivico, città, cap, costoTotale, mancia, timestampRider, timestampAnnullamento, timestampConsegna)
values
	('ORD0001', '2024-06-05 18:00:00', 'Reclamato', 'vlad.rotariu@gmail.com', 'RIST001', 'Via Roma', '10', 'Milano', '20121', 15.00, 0.00, '2024-06-05 18:30:00', null, '2024-06-05 18:45:00'),
	('ORD0002', '2024-06-05 19:00:00', 'Annullato', 'maria.verdi@gmail.com', 'RIST002', 'Via Cavour', '25', 'Torino', '10123', 18.00, 0.00, null, '2024-06-05 19:10:00', null),
	('ORD0003', '2024-06-06 19:45:00', 'In Consegna', 'vlad.rotariu@gmail.com', 'RIST003', 'Via Venezia', '67', 'Varese', '20119', 21.00, 2.00, '2024-06-05 19:55:00', null, null),
	('ORD0004', '2024-01-01 12:30:00', 'Concluso', 'daphne.mount@yahoo.com', 'RIST003', 'Rodriguez Ridge', '199', 'Routeland', '53972', 12.00, 1.00, '2024-01-01 12:47:00', null, '2024-01-01 13:05:00'),
	('ORD0005', '2024-06-02 21:15:00', 'Concluso', 'francesco.bianca@gmail.com', 'RIST004', 'Piazza Navona', '17','Roma', '00130', 80.00, 5.00, '2024-06-02 21:40:00', null, '2024-06-02 22:00:00'),
	('ORD0006', '2024-02-03 19:45:00', 'Reclamato', 'carla.rosin@outlook.com', 'RIST001', 'Via Brunelleschi', '91', 'Firenze', '50125', 16.00, 0.00, '2024-02-03 20:00', null, '2024-02-03 20:30:30');    

insert into categoria (nome)
values
  	('Pizzeria'),
  	('Trattoria'),
  	('Giapponese'),
  	('Cinese'),
  	('Etnico'),
  	('Vegetariano'),
  	('Vegano'),
  	('Hamburger'),
  	('Kebab'),
  	('Gelateria');
	
insert into afferenzaRistorante(ristorante, categoria)
values
	('RIST001', 'Pizzeria'),
	('RIST002', 'Trattoria'),
	('RIST003', 'Hamburger'),
	('RIST004', 'Giapponese'),
	('RIST004', 'Cinese'),
	('RIST005', 'Hamburger');

insert into pietanza (titolo, ristorante, prezzo, sconto, immagine, posizioneClassifica)
values
  	('Margherita', 'RIST001', 8.00, 15, 'IMGMARGHERITA.png', 1),
  	('Marinara', 'RIST001', 7.00, 0, 'IMGMARINARA.png', 20),
  	('Diavola', 'RIST001', 8.50, 0, 'IMGDIAVOLA.png', 3),
  	('Tagliatelle al ragù', 'RIST002', 9.00, 10, 'IMGTAGLI.png', 12),
  	('Lasagne al forno', 'RIST002', 14.00, 0, 'IMGLASAGN.png', 2),
 	('Tortellini in brodo', 'RIST002', 10.00, 25, 'IMGTORT.png', 31),
 	('Sushi Misto', 'RIST004', 25.00, 0, 'IMGSUSHI.png', 4),
  	('Sashimi Misto', 'RIST004', 30.00, 0, 'IMGSASHI.png', 26),
  	('Tempura di Gamberi', 'RIST004', 15.00, 0, 'IMGTEMP.png', 13),
	('Coca Cola', 'RIST003', 3.00, 0, 'IMGCOCA.png', 6),
	('Big Shake', 'RIST005', 5.50, 10, 'IMGSHAKE.png', 10),
	('Crispy McBacon', 'RIST003', 6.00, 15, 'IMGCRISPY.png', 5);
	
insert into carrello (ordine, titolo, ristorante, quantità)
values
	('ORD0001', 'Margherita', 'RIST001', 1),
	('ORD0001', 'Marinara', 'RIST001', 1),
	('ORD0002', 'Tagliatelle al ragù', 'RIST002', 2),
	('ORD0003', 'Crispy McBacon', 'RIST003', 3),
	('ORD0003', 'Coca Cola', 'RIST003', 1),
	('ORD0004', 'Crispy McBacon', 'RIST003', 1),
	('ORD0004', 'Coca Cola', 'RIST003', 2),
	('ORD0005', 'Sushi Misto', 'RIST004', 2),
	('ORD0005', 'Sashimi Misto', 'RIST004', 1),
	('ORD0006', 'Margherita', 'RIST001', 2);
	

insert into ingrediente (nome)
values
  	('Pomodoro'),
  	('Mozzarella'),
  	('Basilico'),
  	('Carne macinata'),
  	('Uova'),
  	('Parmigiano Reggiano'),
  	('Riso'),
  	('Salmone'),
  	('Tonno'),
  	('Gamberi'),
  	('Besciamella'),
  	('Brodo di carne'),
  	('Tortellini'),
  	('Aceto di riso'),
  	('Pesce fresco'),
  	('Farina'),
  	('Acqua'),
	('Hamburger'),
	('Pane'),
	('Sciroppo'),
  	('Alghe Nori');


insert into ricetta (ingrediente, titolo, ristorante)
values
  	('Pomodoro', 'Margherita', 'RIST001'),
  	('Mozzarella', 'Margherita', 'RIST001'),
  	('Basilico', 'Margherita', 'RIST001'),
  	('Pomodoro', 'Marinara', 'RIST001'),
  	('Mozzarella', 'Marinara', 'RIST001'),
  	('Carne macinata', 'Diavola', 'RIST001'),
  	('Pomodoro', 'Diavola', 'RIST001'),
  	('Mozzarella', 'Diavola', 'RIST001'),
  	('Uova', 'Tagliatelle al ragù', 'RIST002'),
  	('Carne macinata', 'Tagliatelle al ragù', 'RIST002'),
  	('Pomodoro', 'Tagliatelle al ragù', 'RIST002'),
  	('Parmigiano Reggiano', 'Tagliatelle al ragù', 'RIST002'),
  	('Uova', 'Lasagne al forno', 'RIST002'),
  	('Carne macinata', 'Lasagne al forno', 'RIST002'),
  	('Besciamella', 'Lasagne al forno', 'RIST002'),
  	('Parmigiano Reggiano', 'Lasagne al forno', 'RIST002'),
  	('Brodo di carne', 'Tortellini in brodo', 'RIST002'),
  	('Tortellini', 'Tortellini in brodo', 'RIST002'),
  	('Parmigiano Reggiano', 'Tortellini in brodo', 'RIST002'),
  	('Riso', 'Sushi Misto', 'RIST004'),
  	('Aceto di riso', 'Sushi Misto', 'RIST004'),
  	('Alghe Nori', 'Sushi Misto', 'RIST004'),
  	('Pesce fresco', 'Sushi Misto', 'RIST004'),
  	('Riso', 'Sashimi Misto', 'RIST004'),
  	('Pesce fresco', 'Sashimi Misto', 'RIST004'),
  	('Gamberi', 'Tempura di Gamberi', 'RIST004'),
  	('Farina', 'Tempura di Gamberi', 'RIST004'),
  	('Acqua', 'Tempura di Gamberi', 'RIST004'),
	('Pane', 'Crispy McBacon', 'RIST003'),
	('Hamburger', 'Crispy McBacon', 'RIST003'),
	('Pomodoro', 'Crispy McBacon', 'RIST003'),
	('Acqua', 'Coca Cola', 'RIST003'),
	('Sciroppo', 'Coca Cola', 'RIST003'),
	('Pane', 'Big Shake', 'RIST005'),
	('Hamburger', 'Big Shake', 'RIST005'),
	('Parmigiano Reggiano', 'Big Shake', 'RIST005'),
	('Pomodoro', 'Big Shake', 'RIST005');

insert into allergene (nome)
values
  	('Lattosio'),
  	('Glutine'),
  	('Uova'),
  	('Pesce'),
  	('Crostacei'),
  	('Frutta a guscio'),
  	('Soia'),
  	('Solfiti');

insert into avvertenze (allergene, titolo, ristorante)
values
  	('Lattosio', 'Margherita', 'RIST001'),
  	('Glutine', 'Margherita', 'RIST001'),
  	('Lattosio', 'Marinara', 'RIST001'),
  	('Glutine', 'Marinara', 'RIST001'),
  	('Lattosio', 'Diavola', 'RIST001'),
  	('Glutine', 'Diavola', 'RIST001'),
  	('Uova', 'Tagliatelle al ragù', 'RIST002'),
  	('Glutine', 'Tagliatelle al ragù', 'RIST002'),
  	('Lattosio', 'Lasagne al forno', 'RIST002'),
  	('Glutine', 'Lasagne al forno', 'RIST002'),
  	('Uova', 'Tortellini in brodo', 'RIST002'),
  	('Glutine', 'Tortellini in brodo', 'RIST002'),
  	('Pesce', 'Sushi Misto', 'RIST004'),
	('Glutine', 'Crispy McBacon', 'RIST003'),
	('Glutine', 'Big Shake', 'RIST005'),
	('Lattosio', 'Big Shake', 'RIST005');
  
insert into lista (nome)
values
  	('Vegetariana'),
  	('Vegana'),
  	('Gluten Free'),
  	('Lattosio Free'),
  	('Pesce Free'),
	('Fast Food'),
	('Bevande'),
  	('Bambini');


insert into afferenzaPietanza (titolo, ristorante, lista)
values
 	('Margherita', 'RIST001', 'Vegetariana'),
  	('Marinara', 'RIST001', 'Vegetariana'),
  	('Tagliatelle al ragù', 'RIST002', 'Bambini'),
  	('Lasagne al forno', 'RIST002', 'Bambini'),
  	('Tortellini in brodo', 'RIST002', 'Pesce Free'),
  	('Sushi Misto', 'RIST004', 'Vegana'),
  	('Sashimi Misto', 'RIST004', 'Lattosio Free'),
  	('Tempura di Gamberi', 'RIST004', 'Lattosio Free'),
	('Crispy McBacon', 'RIST003', 'Fast Food'),
	('Big Shake', 'RIST005', 'Fast Food'),
	('Coca Cola', 'RIST003', 'Bevande');

insert into reclamo (ordine, utente, ristorante, timestampr, testo)
values
  	('ORD0001', 'vlad.rotariu@gmail.com', 'RIST001', '2024-06-05 19:00:00', 'Ordine arrivato in ritardo e con la pizza fredda.'),
	('ORD0005', 'carla.rosin@outlook.com', 'RIST001', '2024-02-03 21:00:00', 'È UNO SCHERZO VERO!!! PIZZA FREDDA, MORSA E RITARDO CONSISTENTE. MAI PIÙ');

insert into rider (codice, stato, mezzoTrasporto, autonomia, gps, numeroConsegne, tempoMedioConsegna, posizioneClassifica)
values
  	('RIDER001', 'Fuori Servizio', 'Bicicletta', null, '45.123456, 9.123456', 15, 25, 2),
  	('RIDER002', 'Occupato', 'Bicicletta Elettrica', null, '45.678910, 9.678910', 20, 20, 1),
 	('RIDER003', 'Disponibile', 'Monopattino', 40, '46.234567, 10.234567', 10, 30, 10);

insert into consegna (ordine, rider, distanzaTotale, tempoTotale)
values
  	('ORD0001', 'RIDER001', 6, 15),
	('ORD0004', 'RIDER002', 5, 18),
	('ORD0005', 'RIDER003', 12, 20),
	('ORD0006', 'RIDER001', 8, 30);

insert into messaggioRider (ordine, timestampm, utente, ruoloUtente, rider, ruoloRider, testo)
values
  	('ORD0001', '2024-06-05 18:30:00', 'vlad.rotariu@gmail.com', 'Destinatario', 'RIDER001', 'Mittente', 'Mi dispiace, il tuo ordine è in ritardo a causa del traffico.'),
  	('ORD0002', '2024-06-05 19:09:00', 'maria.verdi@gmail.com', 'Destinatario', 'RIDER002', 'Mittente', 'Ciao, scusami. Ho avuto un incidente e ritarderò di parecchio..'),
	('ORD0002', '2024-06-05 19:09:30', 'maria.verdi@gmail.com', 'Mittente', 'RIDER002', 'Destinatario', 'Ah caspita.. Mi dispiace. Annullo l ordine allora.'),
  	('ORD0003', '2024-06-06 20:00:00', 'vlad.rotariu@gmail.com', 'Mittente', 'RIDER001', 'Destinatario', 'Ciao, posso chiederti di fare veloce? Ho davvero fame!');

insert into messaggioRistorante (ordine, timestampm, utente, ruoloUtente, ristorante, ruoloRistorante, testo)
values
  	('ORD0001', '2024-06-05 18:10:00', 'vlad.rotariu@gmail.com', 'Destinatario', 'RIST001', 'Mittente', 'Il tuo ordine è stato confermato e in preparazione.'),
  	('ORD0002', '2024-06-05 19:05:00', 'maria.verdi@gmail.com', 'Mittente', 'RIST002', 'Destinatario', 'C è un problema con il rider, stiamo provando a contattarlo.');

insert into recensioneRider (ordine, timestampr, utente, rider, stelle, testo)
values
  	('ORD0001', '2024-06-05 20:45:00', 'vlad.rotariu@gmail.com', 'RIDER001', 4, 'Rider leggermente in ritardo, ma molto gentile. Consigliato!'),
	('ORD0005', '2024-06-02 22:45:00', 'francesco.bianca@gmail.com', 'RIDER003', 5, 'Grazie Ahmed è stato davvero un piacere conoscerti, sei simpatico e gentile! Alla prossima.'),
  	('ORD0004', '2024-01-01 14:35:00', 'daphne.mount@yahoo.com', 'RIDER002', 4, 'Thanks!');
	
insert into recensioneRistorante (ordine, timestampr, utente, ristorante, stelle, testo)
values
  	('ORD0001', '2024-06-05 20:45:00', 'vlad.rotariu@gmail.com', 'RIST001', 5, 'Pizza ottima! Ingredienti freschi e di alta qualità.'),
	('ORD0005', '2024-06-02 22:45:00', 'francesco.bianca@gmail.com', 'RIST004', 5, 'Economico ma delizioso! APPROVATISSIMOOOO'),
  	('ORD0004', '2024-01-01 14:35:00', 'daphne.mount@yahoo.com', 'RIST003', 4, 'Very good');

delete from ordine
where idOrdine like 'ORD0004';

update utente
set email = 'frabianca02@edu.unito.it'
where email like 'francesco.bianca@gmail.com';




