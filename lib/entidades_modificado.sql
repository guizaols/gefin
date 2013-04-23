--
-- PostgreSQL database dump
--

-- Started on 2009-04-01 03:14:42 Pacific Standard Time

SET client_encoding = 'LATIN1';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- TOC entry 1759 (class 0 OID 0)
-- Dependencies: 1362
-- Name: entidade_codent_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('entidade', 'codent'), 16, true);


--
-- TOC entry 1757 (class 0 OID 28236)
-- Dependencies: 1363
-- Data for Name: entidade; Type: TABLE DATA; Schema: public; Owner: admin
--

ALTER TABLE entidade DISABLE TRIGGER ALL;

COPY entidade (codent, dscent, siglaent, codzeus) FROM stdin;
1	FEDERA��O DAS IND�STRIAS NO ESTADO DE MT	FIEMT	513
2	SERVI�O NACIONAL DE APRENDIZAGEM INDUSTRIAL	SENAI-DR-MT	313
3	SERVI�O SOCIAL DA IND�STRIA	SESI-DR-MT	213
4	INSTITUTO EUVALDO LODI	IEL	413
5	CONDOM�NIO CASA DA IND�STRIA NO ESTADO DE MT	CONDOMINIO	613
16	ADADASDADSAD	QS	16
\.


ALTER TABLE entidade ENABLE TRIGGER ALL;

-- Completed on 2009-04-01 03:14:43 Pacific Standard Time

--
-- PostgreSQL database dump complete
--

