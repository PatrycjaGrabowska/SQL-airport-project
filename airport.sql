--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.17
-- Dumped by pg_dump version 9.5.17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: sprawdz_iata(); Type: FUNCTION; Schema: public; Owner: pgrabowska
--

CREATE FUNCTION public.sprawdz_iata() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

IF suma_iata() > 3 THEN

RAISE EXCEPTION 'BŁĄD: suma znaków iata przekroczona';

END IF;

RETURN NEW;

END;

$$;


ALTER FUNCTION public.sprawdz_iata() OWNER TO pgrabowska;

--
-- Name: suma_iata(); Type: FUNCTION; Schema: public; Owner: pgrabowska
--

CREATE FUNCTION public.suma_iata() RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE

suma bigint;

BEGIN

suma := char_length((SELECT kod_lotniska_IATA FROM lotnisko));
RETURN suma;

END;

$$;


ALTER FUNCTION public.suma_iata() OWNER TO pgrabowska;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bilet; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.bilet (
    nr_biletu integer NOT NULL,
    miejsce integer,
    lot integer,
    pasazer integer
);


ALTER TABLE public.bilet OWNER TO pgrabowska;

--
-- Name: model_samolotu; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.model_samolotu (
    id_modelu integer NOT NULL,
    nazwa character varying,
    zasieg numeric,
    masa numeric,
    przeznaczenie character varying,
    miejsca integer
);


ALTER TABLE public.model_samolotu OWNER TO pgrabowska;

--
-- Name: lekkie_samoloty; Type: VIEW; Schema: public; Owner: pgrabowska
--

CREATE VIEW public.lekkie_samoloty AS
 SELECT model_samolotu.id_modelu,
    model_samolotu.nazwa,
    model_samolotu.zasieg,
    model_samolotu.masa,
    model_samolotu.przeznaczenie,
    model_samolotu.miejsca
   FROM public.model_samolotu
  WHERE (model_samolotu.masa < (100000)::numeric);


ALTER TABLE public.lekkie_samoloty OWNER TO pgrabowska;

--
-- Name: linia_lotnicza; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.linia_lotnicza (
    kod_linii_iata character varying NOT NULL,
    nazwa character varying,
    email character varying,
    telefon integer,
    adres character varying
);


ALTER TABLE public.linia_lotnicza OWNER TO pgrabowska;

--
-- Name: lot; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.lot (
    nr_lotu integer NOT NULL,
    wylot character varying,
    przylot character varying,
    data_i_godzina timestamp without time zone NOT NULL,
    samolot integer,
    odprawa integer
);


ALTER TABLE public.lot OWNER TO pgrabowska;

--
-- Name: lotnisko; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.lotnisko (
    kod_lotniska_iata character varying NOT NULL,
    nazwa character varying,
    panstwo character varying,
    miasto character varying
);


ALTER TABLE public.lotnisko OWNER TO pgrabowska;

--
-- Name: lotniska_w_polsce; Type: VIEW; Schema: public; Owner: pgrabowska
--

CREATE VIEW public.lotniska_w_polsce AS
 SELECT lotnisko.kod_lotniska_iata,
    lotnisko.nazwa,
    lotnisko.panstwo,
    lotnisko.miasto
   FROM public.lotnisko
  WHERE ((lotnisko.panstwo)::text = 'Polska'::text);


ALTER TABLE public.lotniska_w_polsce OWNER TO pgrabowska;

--
-- Name: loty_w_xx_wieku; Type: VIEW; Schema: public; Owner: pgrabowska
--

CREATE VIEW public.loty_w_xx_wieku AS
 SELECT lot.nr_lotu,
    lot.wylot,
    lot.przylot,
    lot.data_i_godzina,
    lot.samolot,
    lot.odprawa
   FROM public.lot
  WHERE (lot.data_i_godzina < '2001-01-01 00:00:01'::timestamp without time zone);


ALTER TABLE public.loty_w_xx_wieku OWNER TO pgrabowska;

--
-- Name: miejsca; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.miejsca (
    id_miejsca integer NOT NULL,
    kabina character varying,
    nr_miejsca integer,
    rzad character varying,
    klasa character varying(10),
    samolot integer,
    model integer
);


ALTER TABLE public.miejsca OWNER TO pgrabowska;

--
-- Name: odprawa; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.odprawa (
    id_odprawy integer NOT NULL,
    strefa character varying,
    bramka character varying,
    lotnisko character varying
);


ALTER TABLE public.odprawa OWNER TO pgrabowska;

--
-- Name: pasazerowie; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.pasazerowie (
    id_pasazera integer NOT NULL,
    nr_dokumentu character varying,
    imie character varying,
    nazwisko character varying,
    email character varying,
    nr_telefonu integer,
    adres character varying
);


ALTER TABLE public.pasazerowie OWNER TO pgrabowska;

--
-- Name: samoloty; Type: TABLE; Schema: public; Owner: pgrabowska
--

CREATE TABLE public.samoloty (
    nr_samolotu integer NOT NULL,
    linia_lotnicza character varying,
    model integer
);


ALTER TABLE public.samoloty OWNER TO pgrabowska;

--
-- Name: wlasciciel_biletu; Type: VIEW; Schema: public; Owner: pgrabowska
--

CREATE VIEW public.wlasciciel_biletu AS
 SELECT pasazerowie.id_pasazera,
    pasazerowie.imie,
    pasazerowie.nazwisko,
    bilet.miejsce,
    bilet.lot
   FROM (public.pasazerowie
     JOIN public.bilet ON ((pasazerowie.id_pasazera = bilet.pasazer)));


ALTER TABLE public.wlasciciel_biletu OWNER TO pgrabowska;

--
-- Data for Name: bilet; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.bilet (nr_biletu, miejsce, lot, pasazer) FROM stdin;
101	404	123	1
201	505	321	2
\.


--
-- Data for Name: linia_lotnicza; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.linia_lotnicza (kod_linii_iata, nazwa, email, telefon, adres) FROM stdin;
KC	Air Astana	airastana@gmail.com	123456789	Kazachstan Almaty
LO	LOT	lot@gmail.com	987654321	Polska Warszawa-Chopin
\.


--
-- Data for Name: lot; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.lot (nr_lotu, wylot, przylot, data_i_godzina, samolot, odprawa) FROM stdin;
123	GDN	WAW	2004-10-19 10:23:54	747	1
321	WAW	GDN	1997-01-18 07:12:10	777	2
\.


--
-- Data for Name: lotnisko; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.lotnisko (kod_lotniska_iata, nazwa, panstwo, miasto) FROM stdin;
JFK	Port lotniczy Johna F Kennedyego	USA	Nowy Jork
WAW	Lotnisko Chopina	Polska	Warszawa
GDN	Port lotniczy im. Lecha Wałęsy	Polska	Gdansk
\.


--
-- Data for Name: miejsca; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.miejsca (id_miejsca, kabina, nr_miejsca, rzad, klasa, samolot, model) FROM stdin;
404	1	100	2	Boeing747	1	\N
505	2	101	2	Boeing777	2	\N
\.


--
-- Data for Name: model_samolotu; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.model_samolotu (id_modelu, nazwa, zasieg, masa, przeznaczenie, miejsca) FROM stdin;
747	Boeing	1500	150000	pasazerski	150
777	Boeing	3000	60000	pasazerski	400
\.


--
-- Data for Name: odprawa; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.odprawa (id_odprawy, strefa, bramka, lotnisko) FROM stdin;
1	A	1	WAW
2	B	2	GDN
\.


--
-- Data for Name: pasazerowie; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.pasazerowie (id_pasazera, nr_dokumentu, imie, nazwisko, email, nr_telefonu, adres) FROM stdin;
1	123	Jan	Kowalski	jan@gmail.com	98123432	\N
2	124	Janina	Kowalska	janina@gmail.com	145234222	\N
\.


--
-- Data for Name: samoloty; Type: TABLE DATA; Schema: public; Owner: pgrabowska
--

COPY public.samoloty (nr_samolotu, linia_lotnicza, model) FROM stdin;
747	LO	747
777	KC	777
\.


--
-- Name: bilet_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.bilet
    ADD CONSTRAINT bilet_pkey PRIMARY KEY (nr_biletu);


--
-- Name: linia_lotnicza_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.linia_lotnicza
    ADD CONSTRAINT linia_lotnicza_pkey PRIMARY KEY (kod_linii_iata);


--
-- Name: lot_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.lot
    ADD CONSTRAINT lot_pkey PRIMARY KEY (nr_lotu);


--
-- Name: lotnisko_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.lotnisko
    ADD CONSTRAINT lotnisko_pkey PRIMARY KEY (kod_lotniska_iata);


--
-- Name: miejsca_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.miejsca
    ADD CONSTRAINT miejsca_pkey PRIMARY KEY (id_miejsca);


--
-- Name: model_samolotu_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.model_samolotu
    ADD CONSTRAINT model_samolotu_pkey PRIMARY KEY (id_modelu);


--
-- Name: odprawa_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.odprawa
    ADD CONSTRAINT odprawa_pkey PRIMARY KEY (id_odprawy);


--
-- Name: pasazerowie_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.pasazerowie
    ADD CONSTRAINT pasazerowie_pkey PRIMARY KEY (id_pasazera);


--
-- Name: samoloty_pkey; Type: CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.samoloty
    ADD CONSTRAINT samoloty_pkey PRIMARY KEY (nr_samolotu);


--
-- Name: sprawdz_iata; Type: TRIGGER; Schema: public; Owner: pgrabowska
--

CREATE TRIGGER sprawdz_iata AFTER INSERT OR UPDATE ON public.lotnisko FOR EACH ROW EXECUTE PROCEDURE public.sprawdz_iata();


--
-- Name: bilet_lot_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.bilet
    ADD CONSTRAINT bilet_lot_fkey FOREIGN KEY (lot) REFERENCES public.lot(nr_lotu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bilet_miejsce_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.bilet
    ADD CONSTRAINT bilet_miejsce_fkey FOREIGN KEY (miejsce) REFERENCES public.miejsca(id_miejsca) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bilet_pasazer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.bilet
    ADD CONSTRAINT bilet_pasazer_fkey FOREIGN KEY (pasazer) REFERENCES public.pasazerowie(id_pasazera) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lot_odprawa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.lot
    ADD CONSTRAINT lot_odprawa_fkey FOREIGN KEY (odprawa) REFERENCES public.odprawa(id_odprawy) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lot_przylot_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.lot
    ADD CONSTRAINT lot_przylot_fkey FOREIGN KEY (przylot) REFERENCES public.lotnisko(kod_lotniska_iata) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lot_samolot_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.lot
    ADD CONSTRAINT lot_samolot_fkey FOREIGN KEY (samolot) REFERENCES public.samoloty(nr_samolotu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lot_wylot_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.lot
    ADD CONSTRAINT lot_wylot_fkey FOREIGN KEY (wylot) REFERENCES public.lotnisko(kod_lotniska_iata) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lotnisko_del; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.odprawa
    ADD CONSTRAINT lotnisko_del FOREIGN KEY (lotnisko) REFERENCES public.lotnisko(kod_lotniska_iata) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: miejsca_model_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.miejsca
    ADD CONSTRAINT miejsca_model_fkey FOREIGN KEY (model) REFERENCES public.model_samolotu(id_modelu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: odprawa_lotnisko_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.odprawa
    ADD CONSTRAINT odprawa_lotnisko_fkey FOREIGN KEY (lotnisko) REFERENCES public.lotnisko(kod_lotniska_iata) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: samoloty_linia_lotnicza_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.samoloty
    ADD CONSTRAINT samoloty_linia_lotnicza_fkey FOREIGN KEY (linia_lotnicza) REFERENCES public.linia_lotnicza(kod_linii_iata) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: samoloty_model_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pgrabowska
--

ALTER TABLE ONLY public.samoloty
    ADD CONSTRAINT samoloty_model_fkey FOREIGN KEY (model) REFERENCES public.model_samolotu(id_modelu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

