--
-- PostgreSQL database dump
--

-- Dumped from database version 17.9 (Debian 17.9-1.pgdg12+1)
-- Dumped by pg_dump version 17.5

-- Started on 2026-04-02 01:21:13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 16633)
-- Name: public; Type: SCHEMA; Schema: -; Owner: db_continental_xowx_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO db_continental_xowx_user;

--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: db_continental_xowx_user
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 881 (class 1247 OID 16718)
-- Name: Furnishing; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."Furnishing" AS ENUM (
    'fully_furnished',
    'partially_furnished',
    'unfurnished',
    'kitchen_appliances_only'
);


ALTER TYPE public."Furnishing" OWNER TO db_continental_xowx_user;

--
-- TOC entry 890 (class 1247 OID 17223)
-- Name: HomeType; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."HomeType" AS ENUM (
    'Apartment',
    'Villa',
    'Townhouse'
);


ALTER TYPE public."HomeType" OWNER TO db_continental_xowx_user;

--
-- TOC entry 860 (class 1247 OID 16650)
-- Name: LeadStatus; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."LeadStatus" AS ENUM (
    'ACTIVE',
    'LOST',
    'DUE'
);


ALTER TYPE public."LeadStatus" OWNER TO db_continental_xowx_user;

--
-- TOC entry 875 (class 1247 OID 16696)
-- Name: Market; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."Market" AS ENUM (
    'Primary',
    'Secondary'
);


ALTER TYPE public."Market" OWNER TO db_continental_xowx_user;

--
-- TOC entry 893 (class 1247 OID 18166)
-- Name: PaymentMode; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."PaymentMode" AS ENUM (
    'online',
    'cash',
    'cheque'
);


ALTER TYPE public."PaymentMode" OWNER TO db_continental_xowx_user;

--
-- TOC entry 884 (class 1247 OID 16728)
-- Name: PaymentStatus; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."PaymentStatus" AS ENUM (
    'due',
    'paid',
    'overdue'
);


ALTER TYPE public."PaymentStatus" OWNER TO db_continental_xowx_user;

--
-- TOC entry 872 (class 1247 OID 16691)
-- Name: PropertyType; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."PropertyType" AS ENUM (
    'Rental',
    'OffPlan'
);


ALTER TYPE public."PropertyType" OWNER TO db_continental_xowx_user;

--
-- TOC entry 878 (class 1247 OID 16710)
-- Name: RentFrequency; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."RentFrequency" AS ENUM (
    'monthly',
    'quarterly',
    'yearly'
);


ALTER TYPE public."RentFrequency" OWNER TO db_continental_xowx_user;

--
-- TOC entry 857 (class 1247 OID 16644)
-- Name: Role; Type: TYPE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TYPE public."Role" AS ENUM (
    'USER',
    'ADMIN'
);


ALTER TYPE public."Role" OWNER TO db_continental_xowx_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16634)
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO db_continental_xowx_user;

--
-- TOC entry 221 (class 1259 OID 16669)
-- Name: leads; Type: TABLE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TABLE public.leads (
    id integer NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    email text,
    "propertyId" text,
    status public."LeadStatus" DEFAULT 'ACTIVE'::public."LeadStatus" NOT NULL,
    message text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "developerName" text,
    notes text,
    price double precision,
    "projectName" text,
    type text
);


ALTER TABLE public.leads OWNER TO db_continental_xowx_user;

--
-- TOC entry 220 (class 1259 OID 16668)
-- Name: leads_id_seq; Type: SEQUENCE; Schema: public; Owner: db_continental_xowx_user
--

CREATE SEQUENCE public.leads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.leads_id_seq OWNER TO db_continental_xowx_user;

--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 220
-- Name: leads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: db_continental_xowx_user
--

ALTER SEQUENCE public.leads_id_seq OWNED BY public.leads.id;


--
-- TOC entry 223 (class 1259 OID 16681)
-- Name: occupant_records; Type: TABLE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TABLE public.occupant_records (
    id integer NOT NULL,
    bedrooms integer,
    bathrooms integer,
    city text,
    location text,
    rent double precision,
    completion_date timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    developer_name text NOT NULL,
    latitude double precision,
    longitude double precision,
    property_name text NOT NULL,
    property_type public."PropertyType" DEFAULT 'Rental'::public."PropertyType" NOT NULL,
    property_views text,
    rental_agreement text,
    updated_at timestamp(3) without time zone NOT NULL,
    market public."Market",
    furnishing public."Furnishing",
    amenities text[],
    handover timestamp(3) without time zone,
    email text,
    emi integer,
    image_url text,
    name text NOT NULL,
    offplan_agreement text,
    payment_count integer DEFAULT 1,
    payment_frequency public."RentFrequency",
    phone text NOT NULL,
    price integer,
    locality text,
    home_type text,
    dld integer,
    quood integer,
    other_charges integer,
    penalties integer
);


ALTER TABLE public.occupant_records OWNER TO db_continental_xowx_user;

--
-- TOC entry 222 (class 1259 OID 16680)
-- Name: occupant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: db_continental_xowx_user
--

CREATE SEQUENCE public.occupant_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.occupant_records_id_seq OWNER TO db_continental_xowx_user;

--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 222
-- Name: occupant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: db_continental_xowx_user
--

ALTER SEQUENCE public.occupant_records_id_seq OWNED BY public.occupant_records.id;


--
-- TOC entry 225 (class 1259 OID 16743)
-- Name: payments; Type: TABLE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    emi integer,
    rent integer,
    status public."PaymentStatus" DEFAULT 'due'::public."PaymentStatus" NOT NULL,
    payment_date timestamp(3) without time zone,
    payment_proof text,
    mode_of_payment public."PaymentMode" DEFAULT 'online'::public."PaymentMode" NOT NULL,
    "occupantRecordId" integer,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(3) without time zone
);


ALTER TABLE public.payments OWNER TO db_continental_xowx_user;

--
-- TOC entry 224 (class 1259 OID 16742)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: db_continental_xowx_user
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO db_continental_xowx_user;

--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 224
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: db_continental_xowx_user
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- TOC entry 219 (class 1259 OID 16658)
-- Name: users; Type: TABLE; Schema: public; Owner: db_continental_xowx_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email text NOT NULL,
    name text,
    password text NOT NULL,
    role public."Role" DEFAULT 'USER'::public."Role" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    phone text,
    "profileImage" text
);


ALTER TABLE public.users OWNER TO db_continental_xowx_user;

--
-- TOC entry 218 (class 1259 OID 16657)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: db_continental_xowx_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO db_continental_xowx_user;

--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 218
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: db_continental_xowx_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3265 (class 2604 OID 16672)
-- Name: leads id; Type: DEFAULT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.leads ALTER COLUMN id SET DEFAULT nextval('public.leads_id_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 16684)
-- Name: occupant_records id; Type: DEFAULT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.occupant_records ALTER COLUMN id SET DEFAULT nextval('public.occupant_records_id_seq'::regclass);


--
-- TOC entry 3272 (class 2604 OID 16746)
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- TOC entry 3262 (class 2604 OID 16661)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3433 (class 0 OID 16634)
-- Dependencies: 217
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: db_continental_xowx_user
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
57c35847-6883-4bec-a01d-429244d925b0	bf2a79e1acd6a01e0ce03eee0d0f9b562018f0873a8db5641436fb986d11331f	2025-10-29 23:14:51.912794+00	20251028020532_leads_added	\N	\N	2025-10-29 23:14:50.173749+00	1
efa28b66-1ea2-4154-9a3b-6bd1f7020a0d	448304e852dab48f35e967d376227a018889cf97da9ef26349e3439e52b6d909	2025-10-29 23:14:54.153091+00	20251028055406_add_project_name_to_lead	\N	\N	2025-10-29 23:14:52.601081+00	1
7b2e2577-d9f5-4720-82b2-7d43f1be728d	ee2706ba3f29fdb7ea98736c293049c9dbc657f676ddde96c86cba0fdb86284c	2025-10-29 23:14:56.293622+00	20251028165126_add_occupant_record	\N	\N	2025-10-29 23:14:54.760991+00	1
7ecd0f9c-b8c3-4fa5-996c-d2794f259b18	889590d017fa9db462592623706a1bb513819c9250371d6187c1b41e1ec106e8	2025-10-29 23:14:58.478405+00	20251028170410_add_occupant_record_model	\N	\N	2025-10-29 23:14:56.912107+00	1
88836ca6-3bab-4505-912a-1d38be518cbf	c946836033ebcd18d6ff54a66a42eeb7102ae106534937ae170f725a06d7bb98	2025-10-29 23:15:00.71844+00	20251028235451_occupant_record_feilds_updated	\N	\N	2025-10-29 23:14:59.094245+00	1
5ef36179-c81a-4b82-8e48-5d8c26e13807	20b1588bd1cec348935523731330a1af2720d86e81ff1d05ab0bc7295a30621f	2025-10-29 23:15:03.144002+00	20251029220250_occupant	\N	\N	2025-10-29 23:15:01.402698+00	1
3802e5db-5bb5-4b98-a7e4-9dbe5578a278	96d36d66c153f20b8294c4dbbfa09df33d8358a39c5d17b5cf53fcf130705509	2025-10-30 23:32:29.129781+00	20251030233226_new_changes	\N	\N	2025-10-30 23:32:27.708239+00	1
be8c8f3a-84dd-4746-a679-181345bf2600	ff7b9a26c68a875efab0841bba8b504d22fd232653404f5e791c9b2a8c1c6929	2025-11-02 14:57:53.063409+00	20251103000000_add_cheque_payment_mode	\N	\N	2025-11-02 14:57:52.927589+00	1
a2053677-5a5f-4cd1-a49b-8a3901ae2a55	432b9df63eeda86b04d75457386ce491e293b3c95a6fff2e063b552362e2f2cb	\N	20251103004659_change_offline_to_cash	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251103004659_change_offline_to_cash\n\nDatabase error code: 55P04\n\nDatabase error:\nERROR: unsafe use of new value "cash" of enum type "PaymentMode"\nHINT: New enum values must be committed before they can be used.\n\nPosition:\n[1m  0[0m\n[1m  1[0m -- Add 'cash' to PaymentMode enum\n[1m  2[0m ALTER TYPE "PaymentMode" ADD VALUE IF NOT EXISTS 'cash';\n[1m  3[0m\n[1m  4[0m -- Update all existing records with 'offline' to 'cash'\n[1m  5[1;31m UPDATE "payments" SET "mode_of_payment" = 'cash' WHERE "mode_of_payment" = 'offline';[0m\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E55P04), message: "unsafe use of new value \\"cash\\" of enum type \\"PaymentMode\\"", detail: None, hint: Some("New enum values must be committed before they can be used."), position: Some(Original(191)), where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("enum.c"), line: Some(97), routine: Some("check_safe_enum_use") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251103004659_change_offline_to_cash"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name="20251103004659_change_offline_to_cash"\n             at schema-engine/core/src/commands/apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:226	2025-11-02 19:18:47.791888+00	2025-11-02 19:17:53.806301+00	0
95f709d0-c00f-4cb4-af13-1688be692ccb	d266b54a122b4821a0d680c42fa3dfc7a5865a9c360a66c08d20ea8a7f5a414f	2025-11-02 19:18:48.407097+00	20251103004659_change_offline_to_cash		\N	2025-11-02 19:18:48.407097+00	0
d38bb887-d669-4e58-949b-db2bbadfeb81	3788a44b3b989aa67f4a25eef2adb830db328ed391c215a6b604a1c137dbe42d	2025-11-02 19:19:23.135634+00	20251103004818_update_offline_records_to_cash		\N	2025-11-02 19:19:23.135634+00	0
fbd6845f-094b-4dfa-8708-68b2c4c64faa	e52fdd347e7cc020e97873fac14041be0f71aff1b5266dd40d3b804abd6b734f	2025-11-03 14:17:30.297396+00	20251103193652_add_charges_fields	\N	\N	2025-11-03 14:17:30.159397+00	1
\.


--
-- TOC entry 3437 (class 0 OID 16669)
-- Dependencies: 221
-- Data for Name: leads; Type: TABLE DATA; Schema: public; Owner: db_continental_xowx_user
--

COPY public.leads (id, name, phone, email, "propertyId", status, message, "createdAt", "updatedAt", "developerName", notes, price, "projectName", type) FROM stdin;
1	Fatima Al-Zahra	+971501234567	fatima.alzahra@email.com	PROP-001	ACTIVE	Interested in 2-bedroom apartment with sea view	2025-10-29 23:27:03.126	2025-10-29 23:27:03.126	Emaar Properties	Follow-up scheduled for next week	2500000	Dubai Marina Residences	Apartment
2	Khalid Bin Rashid	+971502345678	khalid.rashid@email.com	PROP-002	ACTIVE	Looking for waterfront villa	2025-10-29 23:27:03.761	2025-10-29 23:27:03.761	Nakheel	Budget approved, ready to proceed	8500000	Palm Jumeirah Villa	Villa
3	Layla Ahmed	+971503456789	layla.ahmed@email.com	PROP-003	DUE	Need information on payment plans	2025-10-29 23:27:04.078	2025-10-29 23:27:04.078	Dubai Properties	Awaiting document verification	12000000	Business Bay Towers	Penthouse
4	Omar Al-Mazrouei	+971504567890	\N	PROP-004	LOST	\N	2025-10-29 23:27:04.398	2025-10-29 23:27:04.398	Meraas	Customer found alternative property	980000	Jumeirah Heights	Studio
\.


--
-- TOC entry 3439 (class 0 OID 16681)
-- Dependencies: 223
-- Data for Name: occupant_records; Type: TABLE DATA; Schema: public; Owner: db_continental_xowx_user
--

COPY public.occupant_records (id, bedrooms, bathrooms, city, location, rent, completion_date, created_at, developer_name, latitude, longitude, property_name, property_type, property_views, rental_agreement, updated_at, market, furnishing, amenities, handover, email, emi, image_url, name, offplan_agreement, payment_count, payment_frequency, phone, price, locality, home_type, dld, quood, other_charges, penalties) FROM stdin;
114	4	5	Dubai	Nad Al Sheba 1	\N	2028-03-30 00:00:00	2026-02-13 10:10:54.98	Meydan Group (L.L.C)	25.1591193	55.3088196	Meydan F016	OffPlan	Community View	\N	2026-02-13 10:10:54.98	Primary	partially_furnished	{Parking,Security,Balcony,Garden}	2028-03-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1770976518162-5d4e7a86b63fa77770b733a54a001c57.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1770977427818-11a6f39b4e4182bcdb78df80b0bfdd97.jpg	30	monthly	553776910	13396032	Nad Al Sheba 1	Villa	\N	\N	\N	\N
120	1	2	Dubai	Business Bay	57605	2028-02-18 00:00:00	2026-02-18 11:06:45.999	Sobha L.L.C	25.1815668	55.27151019999999	Sobha Skyparks 2104	OffPlan	Community View	\N	2026-02-18 11:07:45.251	Primary	partially_furnished	{Gym,Parking,Security,Balcony}	2028-02-18 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1771412766270-652fb87d539c0b5a89b5e4b567c0b884.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1771412772130-deae5295bedb54ffab1ba8cc6362d48c.jpg	30	monthly	581312021	2880250	Business Bay	Apartment	\N	\N	\N	\N
122	1	2	Dubai	al habtoor city	\N	2027-08-02 00:00:00	2026-03-12 11:59:27.524	Al Habtoor Property Development L.L.C	25.1830723	55.2551745	Al habtoor 3613	OffPlan	Burj Khalifa View	\N	2026-03-16 10:54:08.526	Primary	partially_furnished	{Security,Balcony,Parking}	2027-08-02 00:00:00	seydoukane241@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1773316682476-6b9ce209bce191f378ee116bb08df5db.jpg	Seydou kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1773316693911-56725ab35794498dda0aff65dafc45ca.jpg	30	monthly	521835460	1980790	Business Bay	Apartment	79231	0	0	0
129	5	5	Dubai	Dubai Land Residence Complex	\N	2028-03-26 00:00:00	2026-03-27 01:23:41.183	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Islands 2 SD153	OffPlan	Community View	\N	2026-03-27 01:23:41.183	Primary	partially_furnished	{Swimming_Pool,Gym,Parking,Security,Balcony,Garden}	2028-03-26 00:00:00	justkane51@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1774574578183-29254511e48d8fba8604a06f83fc5b7b.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1774574584187-1f3e1d9e9be9c03c606f37b298262ae2.jpg	30	monthly	58 131 2021	3449600	Dubai Islands	Villa	\N	\N	\N	\N
115	1	2	Dubai	Business Bay	\N	2028-02-18 00:00:00	2026-02-18 10:44:05.717	Sobha L.L.C	25.1815668	55.27151019999999	SOBHA SKYPARKS 2904	OffPlan	Community View	\N	2026-02-18 10:44:05.717	Primary	partially_furnished	{Gym,Swimming_Pool,Parking,Security,Balcony,Air_Conditioning}	2028-02-18 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1771411371674-3375fb90182e6ea0952fafecbf60459d.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1771411377651-d892e4fe7a37e774f3f333994690bb2c.jpg	30	monthly	581312021	2898140	Business Bay	Apartment	\N	\N	\N	\N
125	5	5	Dubai	Dubai Land Residence Complex	\N	2028-03-26 00:00:00	2026-03-27 00:49:37.281	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Islands 2 SD212	OffPlan	Community View	\N	2026-03-27 00:49:37.281	Primary	partially_furnished	{Swimming_Pool,Gym,Parking,Security,Balcony,Garden}	2028-03-26 00:00:00	justkane51@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1774572464183-49d01b87c5e16987bbd4407dc39b156a.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1774572477246-7adbdecf4f162281c16f009f6cac097a.jpg	30	monthly	58 131 2021	3499580	Dubai Islands	Villa	\N	\N	\N	\N
130	5	5	Dubai	Dubai Land Residence Complex	\N	2028-03-26 00:00:00	2026-03-27 01:28:01.326	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Islands 2 SD154	OffPlan	Community View	\N	2026-03-27 09:35:23.383	Primary	partially_furnished	{Swimming_Pool,Gym,Parking,Security,Balcony,Garden}	2028-03-26 00:00:00	justkane51@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1774574830852-774ff84db5359d0fb290457201facaae.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1774574837945-fbc40b6c621b4eed71941865b70fe51b.jpg	30	monthly	58 131 2021	3587584	Dubai Islands	Villa	\N	\N	\N	\N
116	1	2	Dubai	Business Bay	\N	2028-02-18 00:00:00	2026-02-18 10:50:54.024	Sobha L.L.C	25.1815668	55.27151019999999	Sobha Skyparks 2804	OffPlan	Community View	\N	2026-02-18 10:50:54.024	Primary	partially_furnished	{Gym,Parking,Security,Balcony}	2028-02-18 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1771411834193-1fbd57a9ba2a11bbe03302b5afa442e5.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1771411837911-1593b0d891835261c82ba37d74be73cc.jpg	30	monthly	581312021	2898140	Business Bay	Apartment	\N	\N	\N	\N
121	2	2	Dubai	al habtoor city	\N	2027-08-02 00:00:00	2026-03-12 11:48:41.629	Al Habtoor Property Development L.L.C	25.1830723	55.2551745	Al habtoor 3614	OffPlan	Burj Khalifa View	\N	2026-03-12 11:48:41.629	Primary	partially_furnished	{Gym,Parking,Security,Balcony}	2027-08-02 00:00:00	kaneseydou241@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1773316022669-b916a325052ceed9a62af61fe23cdcb7.jpg	Seydou kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1773316030567-dcce1542f6a70911a06d306f90623531.jpg	30	monthly	521835460	1980542	Business Bay	Apartment	\N	\N	\N	\N
126	5	5	Dubai	Dubai Land Residence Complex	\N	2028-03-27 00:00:00	2026-03-27 01:01:49.886	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Islands 2 SD215	OffPlan	Community View	\N	2026-03-27 01:01:49.886	Primary	partially_furnished	{Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning}	2028-03-27 00:00:00	justkane51@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1774573258844-5211e21abfcfdcaa26963e91fe8af4d1.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1774573264401-712ef33a6bddd84e1d87ce6ca9cb897d.jpg	30	monthly	58 131 2021	3499580	Dubai Islands	Villa	\N	\N	\N	\N
131	5	5	Dubai	Dubai Land Residence Complex	\N	2028-03-26 00:00:00	2026-03-27 09:22:37.812	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Islands 2 SD125	OffPlan	Community View	\N	2026-03-27 09:31:23.821	Primary	partially_furnished	{Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning}	2028-03-26 00:00:00	justkane51@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1774602282578-6ec463865f8508ad2ccda0b90e47a5c6.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1774603341419-098c7b0c8761e30efa105d22e82a4e2a.jpg	30	monthly	58 131 2021	3587584	Dubai Islands	Villa	\N	\N	\N	\N
62	4	3	Dubai	Al Yalayis 1	\N	2028-12-31 00:00:00	2025-11-07 10:29:24.77	Damac Development(L L C)	25.0142211	55.3088196	Damac Island SD173	OffPlan	Community View	\N	2025-11-14 11:04:55.296	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Heating,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2028-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762511257873-2d02c50fca826c4a38a46fafd143445c.jpg	Seydou kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762511263883-d7ff7e5d52986a6f7cfc6c450cdd21b8.jpg	40	monthly	585831240	2374736	Dubai	Townhouse	93200	1	1	0
61	4	3	Dubai	Al Yalayis 1	\N	2028-12-31 00:00:00	2025-11-07 10:22:17.062	Damac Development(L L C)	25.0142211	55.3088196	Damac Island SD466	OffPlan	Community View	\N	2025-11-14 11:32:45.597	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Parking,Gym,Security,Balcony,Garden,Air_Conditioning,Heating,Jaccuzi,Play_Area,Lobby,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Study,Barbecue_Area}	2028-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762510856727-d90782c326ce5bb6ca34642535406762.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762510860665-49f6d3db3ddfbcb82bf7efc86d51f5e2.jpg	40	monthly	0585831240	2374736	Dubai	Townhouse	93200	1	1	\N
59	3	3	Dubai	Mudon	\N	2027-11-30 00:00:00	2025-11-07 09:38:08.813	Dubai Properties(L.L.C)	25.0234353	55.2716551	Mudon Al Ranim6 	OffPlan	Community View	\N	2025-11-14 13:03:45.477	Primary	partially_furnished	{Security,Parking,Balcony,Air_Conditioning}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762507851984-b7ae87a9be4bdd98e175b9077ac77c93.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762507854593-04eef4d16741a6d50dc889f439022405.jpg	15	monthly	581312021	2973000	Golf City	Villa	118920	1	1	0
63	4	3	Dubai	Al Yalayis 1	\N	2028-12-31 00:00:00	2025-11-07 10:33:53.765	Damac Development(L L C)	25.0142211	55.3088196	Damac Island SD243	OffPlan	Community View	\N	2025-11-14 11:03:59.644	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2028-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762511592301-f765dcac67505e9e026b975e680a6bd0.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762511594786-cda8e46ee313e19c66a1d767153046e2.jpg	40	monthly	585831240	2374736	Dubai	Townhouse	93200	1	1	0
60	4	3	Dubai	Al Yalayis 1	\N	2028-12-12 00:00:00	2025-11-07 10:17:29.639	Damac Development(L L C)	25.0142211	55.3088196	Damac Islands SD445	OffPlan	Community View	\N	2025-11-14 11:33:59.908	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Heating,Play_Area,Lobby,Scenic_View,Wardrobes,Kitchen_Appliances,Barbecue_Area}	2028-12-12 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762510527740-70ce9f1fc7b23077535b07c6adf6e4a2.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762510557134-5b28425ef629cb0a31ab6621819c0f82.jpg	40	monthly	0585831240	2374736	Dubai	Townhouse	93200	1	1	0
117	1	2	Dubai	Business Bay	\N	2028-02-18 00:00:00	2026-02-18 10:55:19.727	Sobha L.L.C	25.1815668	55.27151019999999	Sobha Skyparks 2704	OffPlan	Community View	\N	2026-02-18 10:55:19.727	Primary	partially_furnished	{Parking,Security,Balcony,Gym}	2028-02-18 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1771412069586-4b318a65dce51faca2f105073b452875.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1771412072243-1ddb9e59fc2af6a543f136f1f2cbb183.jpg	30	monthly	581312021	2898140	Business Bay	Apartment	\N	\N	\N	\N
65	4	3	Dubai	Al Yalayis 1	\N	2028-12-31 00:00:00	2025-11-07 10:52:39.851	Damac Development(L L C)	25.0142211	55.3088196	Damac Island SD329	OffPlan	Community View	\N	2025-11-14 11:01:43.228	Primary	unfurnished	{Swimming_Pool,Pets_Allowed,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2028-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762512724174-139ab7767a8e258ab36e5f591d510587.jpg	Seydou kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762512728812-2c3710595d5abc096c6d3d58e289a474.jpg	40	monthly	585831240	2422638	Dubai	Townhouse	95080	1	1	0
68	4	4	Dubai	Golf City	\N	2026-12-31 00:00:00	2025-11-07 11:24:39.713	Damac Development(L L C)	25.0125131	55.234207	Damac Lagoons Morocco SD640	OffPlan	Community View	\N	2025-11-14 12:20:59.238	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2026-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762514566079-6fd49e4a2c18cb8655f030e9c1fb3494.jpg	seydou kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762514569790-20052dc5638d4a1fc5e4833b1e8c1495.jpg	45	monthly	0585831240	3235440	Dubai	Villa	124440	1	1950	0
70	3	3	Dubai	Damac Hills	\N	2027-03-30 00:00:00	2025-11-08 21:28:48.307	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD170	OffPlan	Community View	\N	2025-11-08 21:28:48.307	Primary	unfurnished	{Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Heating,Play_Area,Wardrobes}	2027-03-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762637227041-2395a2b37e46db24c0675afa742f4838.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762637233373-792c1ce3b11f96a53ed6186a962bbd85.jpg	30	monthly	581312021	2820376	Madinat Hind 4	Townhouse	108476	1	1	\N
66	4	3	Dubai	Al Yalayis 1	\N	2028-12-31 00:00:00	2025-11-07 10:54:54.244	Damac Development(L L C)	25.0142211	55.3088196	Damac Islands SD333	OffPlan	Community View	\N	2025-11-14 10:55:22.11	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2028-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762512858899-2ebbee991239bb5fec454e0220f457e0.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762512862273-490a9677485c50b0b777d0b3d9248626.jpg	40	monthly	585831240	2422638	Dubai	Townhouse	95080	1	1	0
67	4	4	Dubai	Al Yalayis 1	\N	2028-12-31 00:00:00	2025-11-07 10:56:50.751	Damac Development(L L C)	25.0142211	55.3088196	Damac Islands SD334	OffPlan	Community View	\N	2025-11-14 11:00:08.592	Primary	unfurnished	{Swimming_Pool,Gym,Parking,Balcony,Security,Garden,Air_Conditioning,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2028-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762512981537-ee4a5ee29778c5461b31c775228b824a.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762512983634-7ccc404245a1a95765c5faf054bb93ff.jpg	40	monthly	0585831240	2422638	Dubai	Townhouse	95080	1	1	0
64	4	3	Dubai	Al Yalayis 1	\N	2028-12-31 00:00:00	2025-11-07 10:37:06.487	Damac Development(L L C)	25.0142211	55.3088196	Damac Island SD368	OffPlan	Community View	\N	2025-11-14 11:02:56.41	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2028-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762511793868-6f80f65141f80529146977f765855205.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762511797943-8cfd5458eba9b63c5288c4a9e92d148f.jpg	40	monthly	0585831240	2374736	Dubai	Townhouse	93200	1	1	0
69	4	4	Dubai	Golf City	\N	2026-12-31 00:00:00	2025-11-07 11:27:15.495	Damac Development(L L C)	25.0125131	55.234207	Damac Lagoons morocco SD641	OffPlan	Community View	\N	2025-11-14 12:20:47.331	Primary	unfurnished	{Pets_Allowed,Swimming_Pool,Gym,Parking,Security,Balcony,Garden,Air_Conditioning,Jaccuzi,Play_Area,Scenic_View,Wardrobes,Spa,Kitchen_Appliances,Barbecue_Area}	2026-12-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762514791605-d8622a9ca4af1b1958067b5b41bb8e79.jpg	seydou kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762514794375-62d07a59cec841a0d58f41da95c174d0.jpg	45	monthly	0585831240	3235440	Dubai	Townhouse	124440	1	1950	0
71	4	3	Dubai	Damac Hills	\N	2027-03-30 00:00:00	2025-11-08 21:38:57.446	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD239	OffPlan	Community View	\N	2025-11-08 21:38:57.446	Primary	unfurnished	{Gym,Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-03-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762637792924-d0d3f4872daf518827b07c58b1609604.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762637797620-0715b94d702972326b5b4a490dcc8271.jpg	30	monthly	581312021	2821353	Madinat Hind 4	Townhouse	108513	1	1	\N
73	4	4	Dubai	Damac Hills	\N	2027-03-31 00:00:00	2025-11-09 19:26:30.357	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD237	OffPlan	Community View	\N	2025-11-09 19:26:30.357	Primary	unfurnished	{Gym,Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762716326756-941d1c60e5949fab3512b2bfc1ef57ad.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762716335340-9a875622c229dddb55663aa947051e1e.jpg	30	monthly	581312021	2821353	Madinat Hind 4	Townhouse	108513	1	1	\N
74	4	4	Dubai	Damac Hills	\N	2027-03-31 00:00:00	2025-11-09 19:38:33.385	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD240	OffPlan	Community View	\N	2025-11-09 19:38:33.385	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Play_Area,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762717020678-eacf1a8f1452d9d67da52f085fd010b9.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762717028038-a79e89ed0f90eee2a9f9e4953c698c54.jpg	30	monthly	581312021	2821353	Madinat Hind 4	Townhouse	108513	1	1	\N
75	4	4	Dubai	Damac Hills	\N	2027-03-31 00:00:00	2025-11-09 20:00:24.834	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD172	OffPlan	Community View	\N	2025-11-09 20:00:24.834	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762718356043-baa5b43c1fbfcb3568ce58318f767b1c.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762718359891-b50533537315c2954dc45ebd12e21216.jpg	30	monthly	581312021	2820376	Madinat Hind 4	Townhouse	108476	1	1	\N
76	4	4	Dubai	Damac Hills	\N	2027-03-31 00:00:00	2025-11-09 20:14:38.12	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD173	OffPlan	Community View	\N	2025-11-09 20:14:38.12	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762719204629-445dd67da90145301673e4073285f279.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762719209818-07a6030c919f8968c51ae57bca00d9c4.jpg	30	monthly	581312021	2820376	Madinat Hind 4	Townhouse	108476	1	1	\N
77	4	4	Dubai	Damac Hills	\N	2027-03-31 00:00:00	2025-11-09 20:19:14.93	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD241	OffPlan	Community View	\N	2025-11-09 20:19:14.93	Primary	unfurnished	{Parking,Security,Air_Conditioning,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762719491268-7460ea1f9ec4ab565a704f1e2e246517.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762719494395-33db7d92e0bc30a3d10637e438fce919.jpg	30	monthly	581312021	2821353	Madinat Hind 4	Townhouse	108513	1	1	\N
78	4	4	Dubai	Damac Hills	\N	2027-03-31 00:00:00	2025-11-09 20:35:42.372	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD238	OffPlan	Community View	\N	2025-11-09 20:35:42.372	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762720488013-aeb5ee490159aee9b00ec1e875679e54.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762720487231-29c341936c1c9eb6a82295b3485e2483.jpg	30	monthly	581312021	2821353	Madinat Hind 4	Townhouse	108513	1	1	\N
118	1	2	Dubai	Business Bay	\N	2028-02-18 00:00:00	2026-02-18 11:00:26.803	Sobha L.L.C	25.1815668	55.27151019999999	Sobha Skyparks 2604	OffPlan	Community View	\N	2026-02-18 11:00:26.803	Primary	partially_furnished	{Parking,Security,Balcony}	2028-02-18 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1771412383899-76983cc73f4d73853cd8874b3316967e.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1771412388924-44ed6ed27d170c2a19a69eadf04fce51.jpg	30	monthly	581312021	2898140	Business Bay	Apartment	\N	\N	\N	\N
79	5	5	Dubai	Dubai Investment Park First	\N	2027-03-31 00:00:00	2025-11-09 21:08:42.609	Damac Development(L L C)	24.9789814	55.1762197	Damac Riverside SD566	OffPlan	Community View	\N	2025-11-10 12:07:18.238	Primary	unfurnished	{Gym,Parking,Security,Air_Conditioning,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762762511925-d736814577c12d43e4e8d071a8ccde6f.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762762565072-281ece55d4d7b463318a274c0d9df28b.jpg	30	monthly	581312021	3968640	Dubai Investments Park	Villa	152640	1	1	0
72	4	4	Dubai	Damac Hills	\N	2027-03-30 00:00:00	2025-11-09 19:09:26.466	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD236	OffPlan	Community View	\N	2025-11-10 10:18:50.963	Primary	unfurnished	{Gym,Parking,Security,Air_Conditioning,Play_Area,Wardrobes}	2027-03-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762715238464-a90d8c7d34684506b775adfb8a4637c2.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762715254804-59947fe80660a59438ff120f76c12af1.jpg	30	monthly	581312021	2821353	Madinat Hind 4	Townhouse	108513	1	1	\N
81	4	4	Dubai	Damac Hills	\N	2027-03-31 00:00:00	2025-11-10 10:22:50.829	Damac Development(L L C)	24.9879316	55.3749762	Damac Park Green2 SD171	OffPlan	Community View	\N	2025-11-10 10:22:50.829	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762770162674-84b1ebae814dcb4a285cee756478ea15.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762770122954-fea6b90f08f9557627fcdee6d2679980.jpg	30	monthly	581312021	2820376	Madinat Hind 4	Townhouse	108476	1	1	\N
83	5	5	Dubai	Dubai Investment Park First	\N	2027-11-30 00:00:00	2025-11-10 11:02:25.579	Damac Development(L L C)	24.9789814	55.1762197	Damac Riverside SD210	OffPlan	Community View	\N	2025-11-10 12:03:36.923	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762772482495-cf6119c28b7c47cd6c45974e353efd87.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762772501830-1c7ea696dde5e53ae9e1ce4bee902107.jpg	30	monthly	581312021	4309760	Dubai Investments Park	Villa	165760	1	1	0
82	5	5	Dubai	Dubai Investment Park First	\N	2027-11-30 00:00:00	2025-11-10 10:48:10.386	Damac Development(L L C)	24.9789814	55.1762197	Damac Riverside SD401	OffPlan	Community View	\N	2025-11-10 12:03:58.569	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762771682672-64de3897e306e53fd135705062c64994.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762771667503-088f2d62cabb7960eff8c3fe9f41a099.jpg	30	monthly	581312021	4281680	Dubai Investments Park	Villa	164680	1	1	0
80	5	5	Dubai	Dubai Investment Park First	\N	2027-03-31 00:00:00	2025-11-10 06:44:53.344	Damac Development(L L C)	24.9789814	55.1762197	Damac riverside SD502	OffPlan	Community View	\N	2025-11-10 12:04:39.745	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-03-31 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762758118266-5062d8f2df3dd317a0d6a759523b212d.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762758136831-a1e131e27a490fd75f52b37ce1549fb6.jpg	30	monthly	581312021	3915600	Dubai Investments Park	Villa	150600	1	1	0
84	5	5	Dubai	Bu Kadra	\N	2027-11-30 00:00:00	2025-11-10 12:46:29.413	Sobha L.L.C	25.1781358	55.3267916	Sobha Reserve SE-V101	OffPlan	Community View	\N	2025-11-10 12:46:29.413	Primary	unfurnished	{Gym,Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762778575459-d6d6bb6918051eebd04689810e81a010.webp	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762778704175-1f0d57f400c7cf0073aa769ebb8f0f71.pdf	30	monthly	581312021	12301154	Dubai	Villa	474228	1	1	\N
85	5	5	Dubai	Bu Kadra	\N	2027-11-30 00:00:00	2025-11-10 12:59:42.506	Sobha L.L.C	25.1781358	55.3267916	Sobha Reserve SE-V 102	OffPlan	Community View	\N	2025-11-10 12:59:42.506	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762779575421-f49e456528c2ae85accd82a14eb60811.webp	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762779497235-09901d06c7ea068b7a560f6ee0f8ca4e.pdf	30	monthly	581312021	12652987	Dubai	Villa	487760	1	1	\N
119	1	2	Dubai	Business Bay	\N	2028-02-18 00:00:00	2026-02-18 11:03:31.99	Sobha L.L.C	25.1815668	55.27151019999999	Sobha Skyparks 2304	OffPlan	Community View	\N	2026-02-18 11:03:31.99	Primary	partially_furnished	{Gym,Parking,Security,Balcony}	2028-02-18 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1771412568088-a5ec1a6bc269baa3294ea02c63916e7c.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1771412573661-8168afc9065cf1a52cb74dab986b980c.jpg	30	monthly	581312021	2880250	Business Bay	Apartment	\N	\N	\N	\N
92	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 08:54:51.005	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD197	OffPlan	Community View	\N	2025-11-14 12:36:34.472	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762851230402-f02241d31ecb06c924518f2b254dfe8f.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762851281430-5a6fe01fda9300d3c8d10301a030e026.jpg	30	monthly	581312021	2722283	Dubai	Villa	104703	1	1	\N
91	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 08:45:53.343	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD198	OffPlan	Community View	\N	2025-11-14 12:37:40.586	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762850709595-49d8ad1b84a953b94b249376e823d03a.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762850738896-26d66ddec48db63c11f0d048cb72650a.jpg	30	monthly	581312021	2722283	Dubai	Villa	104703	1	1	\N
87	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 08:10:50.778	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD580	OffPlan	Community View	\N	2025-11-14 12:46:22.706	Primary	unfurnished	{Parking,Balcony,Security,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762848641029-4724a53d62a5c2b6fe353498c3bee199.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762848583158-32d585f9c0064a691109c90424ab9e6c.jpg	30	monthly	581312021	2325814	Dubai	Villa	89454	1	1	\N
86	4	4	Dubai	Dubai Land Residence Complex	\N	2025-11-28 00:00:00	2025-11-11 08:03:11.346	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD581	OffPlan	Community View	\N	2025-11-14 12:41:01.898	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning}	2025-11-28 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762848176340-d249b2892d9c6255ac4e7efac4b0d5cf.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762848135331-2b9c59b760f7cadcb2b7a250431d9eb5.jpg	30	monthly	581312021	2325814	Dubai	Villa	89454	1	1	\N
89	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 08:27:24.224	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD578	OffPlan	Community View	\N	2025-11-14 12:47:51.238	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762849634848-39b715283d7788823aa339244ca1b8d4.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762849598510-d4ed4197c484a8143ba9030ec8e9b7ee.jpg	30	monthly	581312021	2326833	Dubai	Apartment	89493	1	1	\N
88	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 08:19:10.889	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD579	OffPlan	Community View	\N	2025-11-14 12:49:07.688	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762849133498-f7daebd18abbec2f6a8633f163574784.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762849133260-be753f0c8a3c8999e90d2f7bdf105827.jpg	30	monthly	581312021	2326833	Dubai	Villa	89493	1	1	\N
94	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 09:10:50.147	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD193	OffPlan	Community View	\N	2025-11-14 12:50:25.34	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762852199153-35214568ca331e02f38151b48cc37375.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762852238104-06be70031c3d53af1f8b0db840ace2ea.jpg	30	monthly	581312021	2722283	Dubai	Villa	104703	1	1	\N
90	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 08:36:01.219	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD199	OffPlan	Community View	\N	2025-11-14 12:55:45.352	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762850152987-ee1debd2843db257016fce9fcaaab134.jpg	Seydou Kane 	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762850027964-084a3f8ae400c4958d13964d142f14f6.jpg	30	monthly	581312021	2722283	Dubai	Villa	104703	1	1	\N
48	5	5	Dubai	Bu Kadra	\N	2026-06-30 00:00:00	2025-11-06 09:34:25.299	Sobha Developers L.L.C (Branch)	25.1781358	55.3267916	Sobha Hartland 2 villas SE-V112	OffPlan	Community View	\N	2025-12-05 21:11:55.465	Primary	unfurnished	{Swimming_Pool,Parking,Security,Balcony,Garden,Air_Conditioning,Play_Area,Kitchen_Appliances,Barbecue_Area}	2026-06-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762421452718-5a50849d83239c3390bc530edc65ff0e.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762512254732-a97682680e2d6b65ef7d361accd1df4f.jpg	70	monthly	581312021	35125553	Ras Al Khor Industrial Area 1	Villa	1348220	1348220	1	0
95	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 09:17:42.92	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD192	OffPlan	Community View	\N	2025-11-11 09:17:42.92	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762852655660-20426d69b99de054e175e491b7dbd627.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762852614958-8240d832f64a6530695f7bfddcc08c67.jpg	30	monthly	581312021	2617580	Dubai	Villa	104703	1	1	\N
93	4	4	Dubai	Dubai Land Residence Complex	\N	2027-11-30 00:00:00	2025-11-11 09:03:25.332	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Suncity SD194	OffPlan	Community View	\N	2025-11-14 12:33:17.409	Primary	unfurnished	{Parking,Security,Balcony,Air_Conditioning,Wardrobes}	2027-11-30 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1762851797222-9c5893fe6341f29c59a6148f062d43e7.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1762851758094-339ca69eca4cd9990156b68a112fad46.jpg	30	monthly	581312021	2722283	Dubai	Villa	104703	1	1	\N
110	2	2	Dubai	Mena Jabal Ali	\N	2029-01-19 00:00:00	2026-01-19 12:50:48.355	Azizi Developments L.L.C	24.9857145	55.0272904	Azizi wares 525	OffPlan	Community View	\N	2026-02-17 11:26:43.041	Primary	partially_furnished	{Parking,Balcony,Air_Conditioning}	2029-01-19 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1768826985364-3ab0256a662f37147223a8db8e98e2d6.jpg	Seydou kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1768826989064-1f1732ad102b163a16684cfb30922dda.jpg	30	monthly	585831240	1536480	Mina Jebel Ali	Apartment	\N	\N	\N	\N
109	2	2	Dubai	Mena Jabal Ali	\N	2029-01-19 00:00:00	2026-01-19 12:47:57.194	Azizi Developments L.L.C	24.9857145	55.0272904	Azizi wares 625	OffPlan	Community View	\N	2026-02-17 11:38:11.159	Primary	partially_furnished	{Parking,Security,Air_Conditioning}	2029-01-19 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1768826839437-a8401726f08a72cb4d353e34bd728b93.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1768826846292-d3278643e08db168d8c5f841946b0fbc.jpg	30	monthly	585831240	1537450	Mina Jebel Ali	Apartment	\N	\N	\N	\N
107	2	2	Dubai	Mena Jabal Ali	\N	2028-01-19 00:00:00	2026-01-19 12:35:00.241	Azizi Developments L.L.C	24.9857145	55.0272904	Azizi wares 725	OffPlan	Community View	\N	2026-02-17 11:40:23.963	Primary	partially_furnished	{Gym,Parking,Security,Balcony,Air_Conditioning}	2028-01-19 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1768825989082-4f0db4cbf7b42a0a3f4a5bde4065f548.jpg	SEYDOU KANE	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1768826011937-c6785080e10117be406522321e83cbae.jpg	30	monthly	585831240	1538420	Mina Jebel Ali	Apartment	\N	\N	\N	\N
123	1	1	Dubai	al habtoor city	\N	2027-08-02 00:00:00	2026-03-12 12:09:11.595	Al Habtoor Property Development L.L.C	25.1830723	55.2551745	Al habtoor2314	OffPlan	Burj Khalifa View	\N	2026-03-12 12:09:11.595	Primary	partially_furnished	{Parking,Security,Balcony}	2027-08-02 00:00:00	seydoukane241@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1773317288217-205f483b901bae0384d2221f6dda9748.jpg	seydou kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1773317292894-d1e1e4fbe636b28fd6931bb6eee2deca.jpg	30	monthly	521835460	1917333	Business Bay	Apartment	\N	\N	\N	\N
100	4	4	Dubai	Dubai Silicon Oasis	270000	\N	2025-11-20 16:42:22.877	Dubai Properties(L.L.C)	25.1250606	55.3837419	Cedre Villa 	Rental	Community View	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1763656879707-57e1631176732874f1f7e6a88fcaa067.jpg	2025-11-20 16:42:22.877	Primary	partially_furnished	{Parking,Security,Balcony}	\N	maxime.fages@gmail.com	\N	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1763656871433-6d3534e4df114fecac139a200501ee19.jpg	Maxime Olivier Fages	\N	1	yearly	585208370	\N	Dubai Silicon Oasis	Villa	1	1	1	\N
101	3	3	Dubai	Dubai Silicon Oasis	157660	\N	2025-11-20 16:52:54.903	Dubai Properties(L.L.C)	25.1250606	55.3837419	Cedre Villa	Rental	Community View	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1763657526386-591356eac73bbfe8d2f602de74bc411d.jpg	2025-11-20 16:52:54.903	Primary	partially_furnished	{Parking,Security,Balcony}	\N	Ahpfouad@gmail.com	\N	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1763657516042-d77a1c6a77e3cfcd903b5b79dbc6a64c.jpg	Ahmed Fouad	\N	1	yearly	504569108	\N	Dubai Silicon Oasis	Villa	1	1	1	\N
102	4	4	Dubai	Dubai Silicon Oasis	170000	\N	2025-11-20 16:55:54.767	Dubai Properties(L.L.C)	25.1250606	55.3837419	Cedre Villa 	Rental	Community View	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1763657700678-0d81b33c5d6983296d822b5b0602f6eb.jpg	2025-11-20 16:55:54.767	Primary	partially_furnished	{Parking,Security,Balcony}	\N	taffmorris88@hotmail.com	\N	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1763657694412-0d807a87969b6920964592facf0df510.jpg	Teifion Morris	\N	1	yearly	555540412	\N	Dubai Silicon Oasis	Villa	1	1	1	\N
103	3	3	Dubai	Business Bay	200000	\N	2025-11-20 16:59:16.548	Damac Development(L L C)	25.1815668	55.27151019999999	Damac by Paramount	Rental	Burj Khalifa View	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1763657881259-af2be6c7edeac1f8fd4fb463bcaa5f75.jpg	2025-11-20 16:59:16.548	Primary	partially_furnished	{Parking,Security,Balcony}	\N	okrahselorm@gmail.com	\N	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1763657875533-edfb6ca001d0e90d85898aaa1e21ca6f.jpg	Selorm Isaac	\N	1	yearly	522157876	\N	Business Bay	Apartment	1	1	1	\N
106	2	4	Abu Dhabi	Dubai	200	\N	2025-11-22 17:11:44.578	1b Tower Co. L.L.C	25.2048493	55.2707828	sameer	Rental	Burj Khalifa View	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1763831205168-235922db32da05da5805ce23d2c4981d.png	2025-11-22 17:11:44.578	Primary	unfurnished	{Garden,Balcony,Security,Parking,Gym}	\N	mrao27@gmail.com	\N	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1763831227020-97e074e2e8312c0d31305f827728b3ac.jpg	sameer	\N	20	monthly	767543678	20000	Al Sufouh 2	Apartment	3	3	33	3
108	0	0	Dubai	Nad Al Sheba 1	\N	2028-01-19 00:00:00	2026-01-19 12:44:27.183	Azizi Developments L.L.C	25.1591193	55.3088196	Azizi Riviera68	OffPlan	Community View	\N	2026-01-19 12:44:27.183	Primary	unfurnished	{Security}	2028-01-19 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1768826554939-ff7e310a6e1ef1d77d0abfb6abee83ed.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1768826562314-a1f518bac597a4c824e840ad61c3b5ba.jpg	30	monthly	585831240	5032800	Nad Al Sheba 1	Apartment	\N	\N	\N	\N
111	1	1	Dubai	Mena Jabal Ali	\N	2029-01-19 00:00:00	2026-01-19 12:53:18.264	Azizi Developments L.L.C	24.9857145	55.0272904	Azizi Wares	OffPlan	Community View	\N	2026-01-19 12:53:18.264	Primary	partially_furnished	{Parking,Air_Conditioning}	2029-01-19 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1768827164633-902d59939c6043e01724ebf4d7bb8aa7.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1768827180448-0cf49ac85dc34f52a8766646d3898c6e.jpg	30	monthly	585831240	1002010	Mina Jebel Ali	Apartment	\N	\N	\N	\N
113	2	2	Dubai	Al Jadaf	\N	2029-01-19 00:00:00	2026-01-19 13:09:13.947	Azizi Developments L.L.C	25.216757	55.3309395	Azizi David	OffPlan	Community View	\N	2026-01-20 07:11:27.048	Primary	partially_furnished	{Parking,Air_Conditioning,Balcony,Furnished}	2029-01-19 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1768893045998-67be45a76159170faf00e5be031d1e27.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1768827989343-bb5f3086e1e95076e576fef293d8564a.jpg	30	monthly	585831240	1677130	Al Jaddaf	Apartment	\N	\N	\N	\N
112	1	1	Dubai	Al Jadaf	\N	2028-01-19 00:00:00	2026-01-19 13:03:41.362	Azizi Developments L.L.C	25.216757	55.3309395	Azizi David 614	OffPlan	Community View	\N	2026-02-17 11:35:07.392	Primary	partially_furnished	{Parking,Air_Conditioning,Balcony,Furnished}	2028-01-19 00:00:00	justkane31@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1768893116276-9ef732a8bc2eb703f408088e0402411a.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1768893135276-c5e50431f85e765e1617def1e4084a71.jpg	30	monthly	585831240	1346360	Al Jaddaf	Apartment	\N	\N	\N	\N
124	1	2	Dubai	al habtoor city	\N	2027-08-02 00:00:00	2026-03-12 12:32:33.5	Al Habtoor Property Development L.L.C	25.1830723	55.2551745	Al habtoor 1105	OffPlan	Burj Khalifa View	\N	2026-03-12 12:32:33.5	Primary	partially_furnished	{Parking,Security,Balcony}	2027-08-02 00:00:00	seydoukane241@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1773318701284-4e472ca7c8e46c9d2624419eb19e29b5.jpg	seydou kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1773318706479-c6e920d94aade04cbfabc9cd30db43bd.jpg	30	monthly	521835460	3643525	Business Bay	Apartment	\N	\N	\N	\N
128	5	5	Dubai	Dubai Land Residence Complex	\N	2028-03-26 00:00:00	2026-03-27 01:18:54.548	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Islands 2 SD129	OffPlan	Community View	\N	2026-03-27 09:37:48.135	Primary	partially_furnished	{Swimming_Pool,Gym,Parking,Security,Balcony,Garden}	2028-03-26 00:00:00	justkane51@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1774574277531-eaa7a78f2e972f16a1b30fc281f19566.jpg	Seydou Kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1774574287796-ca1f151c610232ba78a4a96bee7a5f2a.jpg	30	monthly	58 131 2021	3587584	Dubai Islands	Villa	\N	\N	\N	\N
127	5	5	Dubai	Dubai Land Residence Complex	\N	2028-03-26 00:00:00	2026-03-27 01:06:28.023	Damac Development(L L C)	25.0921185	55.37977739999999	Damac Islands 2 SD122	OffPlan	Community View	\N	2026-03-27 09:38:50.419	Primary	partially_furnished	{Gym,Parking,Security,Balcony,Garden,Swimming_Pool}	2028-03-26 00:00:00	justkane51@gmail.com	15000	https://continentalimages.s3.ap-south-1.amazonaws.com/property-images/1774573553734-917db81c1bc9603e18e86be6201715be.jpg	Seydou kane	https://continentalimages.s3.ap-south-1.amazonaws.com/agreements/1774573558272-492dffb38b22bdcacdfb8ca67e5317ec.jpg	30	monthly	58 131 2021	4094126	Dubai Islands	Villa	\N	\N	\N	\N
\.


--
-- TOC entry 3441 (class 0 OID 16743)
-- Dependencies: 225
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: db_continental_xowx_user
--

COPY public.payments (id, emi, rent, status, payment_date, payment_proof, mode_of_payment, "occupantRecordId", created_at, updated_at) FROM stdin;
1330	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1332	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1334	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
145	303246	\N	due	2026-04-03 12:01:20.575	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 12:01:21.156
146	303246	\N	due	2026-05-03 12:01:20.575	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 12:01:21.156
147	303246	\N	due	2026-06-03 12:01:20.575	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 12:01:21.156
148	303246	\N	due	2026-07-03 12:01:20.575	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 12:01:21.156
149	303246	\N	due	2026-08-03 12:01:20.575	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 12:01:21.156
140	197300	\N	paid	2025-11-03 21:07:13.496	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 17:07:28.22
141	197300	\N	paid	2025-11-03 21:55:46.387	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 17:55:59.648
142	197300	\N	paid	2025-11-03 21:56:03.573	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 17:56:09.906
143	197300	\N	paid	2025-11-03 21:56:12.859	\N	online	\N	2025-11-03 12:01:21.156	2025-11-03 17:56:20.591
144	148650	\N	paid	2025-11-04 00:00:00	\N	online	\N	2025-11-03 12:01:21.156	2025-11-07 18:34:20.187
137	300000	\N	due	2025-12-02 17:20:20.775	\N	online	\N	2025-11-02 17:20:21.043	2025-11-02 17:20:21.043
138	300000	\N	due	2026-01-02 17:20:20.775	\N	online	\N	2025-11-02 17:20:21.043	2025-11-02 17:20:21.043
139	300000	\N	due	2026-02-02 17:20:20.775	\N	online	\N	2025-11-02 17:20:21.043	2025-11-02 17:20:21.043
136	200000	\N	due	2025-11-02 21:21:20.546	\N	online	\N	2025-11-02 17:20:21.043	2025-11-03 05:45:23.595
1336	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
110	\N	30000	due	2026-01-31 21:04:16.913	\N	online	\N	2025-11-01 21:20:00.072	\N
111	\N	30000	due	2026-03-31 21:04:16.913	\N	online	\N	2025-11-01 21:20:00.072	\N
167	\N	20000	due	2025-12-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
153	\N	900000	due	2025-12-03 15:21:14.752	\N	online	\N	2025-11-03 15:21:14.991	2025-11-03 15:21:14.991
168	\N	20000	due	2026-01-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
152	\N	900003	paid	2025-11-05 15:36:23.048	\N	cash	\N	2025-11-03 15:21:14.991	2025-11-05 15:36:31.86
186	23300	\N	due	2025-11-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
187	23300	\N	due	2025-12-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
127	1674504	\N	due	2026-04-01 21:16:01.781	\N	online	\N	2025-11-01 21:20:00.072	\N
188	23300	\N	due	2026-01-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
189	23300	\N	due	2026-02-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
190	23300	\N	due	2026-03-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
169	\N	20000	due	2026-02-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
191	23300	\N	due	2026-04-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
1338	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1340	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1341	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1342	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1343	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1344	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1345	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1346	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1347	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1348	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1349	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1350	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1351	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
192	23300	\N	due	2026-05-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
193	23300	\N	due	2026-06-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
120	80000	\N	due	2026-03-31 21:21:28.514	\N	online	\N	2025-11-01 21:20:00.072	\N
154	\N	2000	paid	2025-11-05 17:40:57.745	\N	online	\N	2025-11-03 15:48:12.125	2025-11-05 12:11:03.396
119	80000	\N	due	2025-11-01 21:24:56.299	\N	online	\N	2025-11-01 21:20:00.072	2025-11-03 05:45:23.595
104	2000	\N	due	2025-11-02 21:05:12.866	\N	online	\N	2025-11-01 21:20:00.072	2025-11-03 05:45:23.595
112	\N	30000	due	2026-03-31 21:04:16.913	\N	online	\N	2025-11-01 21:20:00.072	\N
113	\N	30000	due	2026-05-31 21:04:16.913	\N	online	\N	2025-11-01 21:20:00.072	\N
114	\N	30000	due	2026-05-31 21:04:16.913	\N	online	\N	2025-11-01 21:20:00.072	\N
118	59649	\N	paid	2025-11-05 22:55:30.546	\N	online	\N	2025-11-01 21:20:00.072	2025-11-05 17:25:53.997
117	200000	\N	paid	2025-11-05 00:00:00	\N	cash	\N	2025-11-01 21:20:00.072	2025-11-06 02:55:25.987
116	80000	\N	paid	2025-11-06 06:54:25.915	\N	online	\N	2025-11-01 21:20:00.072	2025-11-06 02:54:29.801
170	\N	20000	due	2026-03-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
171	\N	20000	due	2026-04-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
172	\N	20000	due	2026-05-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
173	\N	20000	due	2026-06-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
155	\N	2000	paid	2025-11-05 17:40:59.677	\N	online	\N	2025-11-03 15:48:12.125	2025-11-05 12:11:17.913
150	\N	45678989	paid	2025-11-05 17:49:09.299	\N	online	\N	2025-11-03 15:06:11.952	2025-11-05 12:19:18.293
151	\N	456789567	paid	2025-11-05 17:49:27.72	\N	online	\N	2025-11-03 15:06:11.952	2025-11-05 12:19:38.982
134	30080	\N	paid	2025-11-05 18:22:59.609	\N	cheque	\N	2025-11-02 10:39:12.968	2025-11-05 18:23:08.334
133	6543678	\N	paid	2025-11-05 18:23:11.359	\N	online	\N	2025-11-02 10:39:12.968	2025-11-05 18:23:19.306
135	10022	\N	paid	2025-11-05 18:23:26.188	https://continentalimages.s3.ap-south-1.amazonaws.com/payment-proofs/1762367011377-d1573c4e0c2a8559b6f991e197c521ff.jpg	online	\N	2025-11-02 10:39:12.968	2025-11-05 18:25:19.385
130	\N	20002	paid	2025-11-05 18:30:00	https://continentalimages.s3.ap-south-1.amazonaws.com/payment-proofs/1762367903506-fd12c80928d7e39377916652ca2a8261.jpg	online	\N	2025-11-02 10:36:04.854	2025-11-05 18:38:39.549
131	\N	20000	paid	2025-11-06 11:55:46.406	\N	online	\N	2025-11-02 10:36:04.854	2025-11-06 11:55:48.947
132	\N	20000	paid	2025-11-06 11:55:54.003	\N	online	\N	2025-11-02 10:36:04.854	2025-11-06 11:55:55.821
194	23300	\N	due	2026-07-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
195	23300	\N	due	2026-08-06 08:55:13.905	\N	online	\N	2025-11-06 08:55:14.34	2025-11-06 08:55:14.34
156	297300	\N	paid	2025-11-03 20:50:13.767	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:50:36.984
157	297300	\N	paid	2025-11-03 20:50:39.163	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:50:43.205
158	297300	\N	paid	2025-11-03 20:50:44.686	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:50:46.56
159	148650	\N	paid	2025-11-03 20:50:49.507	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:51:04.195
160	148650	\N	paid	2025-11-03 20:51:05.715	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:51:18.658
161	148650	\N	paid	2025-11-03 20:51:22.534	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:51:28.377
162	148650	\N	paid	2025-11-03 20:51:30.251	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:51:34.699
163	148650	\N	paid	2025-11-03 20:51:37.968	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:51:42.738
164	148650	\N	paid	2025-11-03 20:51:48.119	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:51:52.339
165	1189200	\N	paid	2025-11-03 20:52:21.202	\N	online	\N	2025-11-03 16:49:04.651	2025-11-03 16:52:36.398
1331	25491	\N	paid	2024-11-08 00:00:00	\N	cash	90	2025-11-11 08:36:01.893	2025-11-11 08:38:06.466
1335	393589	\N	paid	2024-12-12 00:00:00	\N	cash	90	2025-11-11 08:36:01.893	2025-11-11 08:39:42.447
1337	268	\N	paid	2025-01-03 00:00:00	\N	cash	90	2025-11-11 08:36:01.893	2025-11-11 08:40:29.156
1339	102918	\N	paid	2025-10-29 00:00:00	\N	cash	90	2025-11-11 08:36:01.893	2025-11-11 08:40:56.116
121	\N	183000	paid	2025-11-05 21:24:46.454	\N	online	\N	2025-11-01 21:20:00.072	2025-11-05 17:24:50.036
1352	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
205	2476000	\N	paid	2024-07-12 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:34:42.297
197	5000000	\N	paid	2024-07-12 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:21:34.659
200	1621029	\N	paid	2024-07-15 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:35:49.386
199	4000000	\N	paid	2024-07-10 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:20:33.524
225	174303	\N	due	2026-07-06 11:56:11.036	\N	online	\N	2025-11-06 11:56:11.56	2025-11-06 11:56:11.56
226	174303	\N	due	2026-08-06 11:56:11.036	\N	online	\N	2025-11-06 11:56:11.56	2025-11-06 11:56:11.56
227	174303	\N	due	2026-09-06 11:56:11.036	\N	online	\N	2025-11-06 11:56:11.56	2025-11-06 11:56:11.56
217	191733	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 11:56:11.56	2025-11-06 12:02:08.868
218	191733	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 11:56:11.56	2025-11-06 12:02:56.517
219	95866	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 11:56:11.56	2025-11-06 12:03:57.688
220	95866	\N	paid	2023-12-31 00:00:00	\N	cheque	\N	2025-11-06 11:56:11.56	2025-11-06 12:04:35.893
221	95866	\N	paid	2024-01-24 00:00:00	\N	cheque	\N	2025-11-06 11:56:11.56	2025-11-06 12:05:47.746
235	331230	\N	due	2026-06-06 12:17:53.599	\N	online	\N	2025-11-06 12:17:54.101	2025-11-06 12:17:54.101
236	331230	\N	due	2026-07-06 12:17:53.599	\N	online	\N	2025-11-06 12:17:54.101	2025-11-06 12:17:54.101
237	331230	\N	due	2026-08-06 12:17:53.599	\N	online	\N	2025-11-06 12:17:54.101	2025-11-06 12:17:54.101
238	331230	\N	due	2026-09-06 12:17:53.599	\N	online	\N	2025-11-06 12:17:54.101	2025-11-06 12:17:54.101
228	364352	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 12:17:54.101	2025-11-06 12:19:37.721
229	364352	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 12:17:54.101	2025-11-06 12:20:24.675
230	182176	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 12:17:54.101	2025-11-06 12:21:03.346
244	99027	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 12:33:36.483	2025-11-06 12:42:17.471
245	99027	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 12:33:36.483	2025-11-06 12:42:52.959
246	180049	\N	due	2026-06-06 12:33:35.996	\N	online	\N	2025-11-06 12:33:36.483	2025-11-06 12:33:36.483
247	180049	\N	due	2026-07-06 12:33:35.996	\N	online	\N	2025-11-06 12:33:36.483	2025-11-06 12:33:36.483
248	180049	\N	due	2026-08-06 12:33:35.996	\N	online	\N	2025-11-06 12:33:36.483	2025-11-06 12:33:36.483
249	180049	\N	due	2026-09-06 12:33:35.996	\N	online	\N	2025-11-06 12:33:36.483	2025-11-06 12:33:36.483
239	198054	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 12:33:36.483	2025-11-06 12:35:09.804
335	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
1353	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
105	387000	\N	due	2025-11-04 00:00:00	\N	online	\N	2025-11-01 21:20:00.072	2025-11-03 05:45:23.595
106	187000	\N	paid	2025-11-05 17:40:13.698	\N	online	\N	2025-11-01 21:20:00.072	2025-11-05 12:10:14.649
103	187656	\N	paid	2025-11-05 17:40:24.894	\N	online	\N	2025-11-01 21:20:00.072	2025-11-05 12:10:26.458
340	91336	\N	paid	2025-04-25 00:00:00	\N	cash	60	2025-11-07 10:17:30.148	2025-11-14 11:45:59.573
222	95866	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 11:56:11.56	2025-11-06 12:06:24.334
223	95866	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 11:56:11.56	2025-11-06 12:07:26.929
224	17823	\N	due	2026-06-06 11:56:11.036	\N	online	\N	2025-11-06 11:56:11.56	2026-03-12 11:28:54.902
231	182176	\N	paid	2023-12-31 00:00:00	\N	cheque	\N	2025-11-06 12:17:54.101	2025-11-06 12:22:10.695
208	198079	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 10:47:57.764	2026-03-12 11:18:59.073
232	182176	\N	paid	2024-01-24 00:00:00	\N	cheque	\N	2025-11-06 12:17:54.101	2025-11-06 12:23:17.274
233	182176	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 12:17:54.101	2025-11-06 12:24:10.674
234	182176	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 12:17:54.101	2025-11-06 12:24:50.408
252	\N	2000	due	2026-01-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
261	\N	20000	due	2025-12-06 16:51:49.952	\N	online	\N	2025-11-06 16:51:52.765	2025-11-06 16:51:52.765
115	\N	30000	due	2026-07-31 21:04:16.913	\N	online	\N	2025-11-01 21:20:00.072	\N
107	\N	78769	paid	2025-11-06 21:32:38.499	\N	online	\N	2025-11-01 21:20:00.072	2025-11-06 16:02:44.001
108	\N	10000	paid	2025-11-06 21:33:26.113	\N	online	\N	2025-11-01 21:20:00.072	2025-11-06 16:03:32.044
274	\N	\N	due	2025-11-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
275	\N	\N	due	2025-12-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
276	\N	\N	due	2026-01-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
266	\N	\N	due	2026-01-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
267	\N	\N	due	2026-02-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
268	\N	\N	due	2026-03-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
269	\N	\N	due	2026-04-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
270	\N	\N	due	2026-05-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
271	\N	\N	due	2026-06-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
272	\N	\N	due	2026-07-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
273	\N	\N	due	2026-08-06 17:08:21.994	\N	online	\N	2025-11-06 17:08:26.462	2025-11-06 17:08:26.462
262	\N	20000	due	2026-01-06 16:51:49.952	\N	online	\N	2025-11-06 16:51:52.765	2025-11-06 16:51:52.765
263	\N	20000	due	2026-02-06 16:51:49.952	\N	online	\N	2025-11-06 16:51:52.765	2025-11-06 16:51:52.765
260	\N	30000	paid	2025-11-06 16:51:49.952	\N	online	\N	2025-11-06 16:51:52.765	2025-11-06 17:28:40.341
253	\N	2000	due	2026-02-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
254	\N	2000	due	2026-03-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
255	\N	2000	due	2026-04-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
256	\N	2000	due	2026-05-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
257	\N	2000	due	2026-06-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
258	\N	2000	due	2026-07-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
259	\N	2000	due	2026-08-06 13:09:27.983	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:09:31.749
250	\N	2000	paid	2025-11-06 13:11:33.35	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:11:35.744
251	\N	20000	paid	2025-11-06 13:12:50.85	\N	online	\N	2025-11-06 13:09:31.749	2025-11-06 13:12:55.381
240	198054	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 12:33:36.483	2025-11-06 12:36:02.976
337	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
339	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
341	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
343	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
241	99027	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 12:33:36.483	2025-11-06 12:36:45.828
345	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
204	1	\N	paid	2024-07-30 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:36:53.514
242	99027	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 12:33:36.483	2025-11-06 12:38:01.412
201	1	\N	paid	2024-07-17 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:37:43.573
202	1	\N	paid	2024-07-23 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:37:27.815
203	1	\N	paid	2024-07-27 00:00:00	\N	cash	48	2025-11-06 09:34:25.764	2025-11-07 11:37:07.936
196	3367671	\N	paid	2024-07-10 00:00:00	\N	cheque	48	2025-11-06 09:34:25.764	2025-11-07 11:19:57.113
338	3019	\N	paid	2025-02-13 00:00:00	\N	cheque	60	2025-11-07 10:17:30.148	2025-11-08 09:17:42.414
243	99027	\N	paid	2023-12-31 00:00:00	\N	cheque	\N	2025-11-06 12:33:36.483	2025-11-06 12:40:07.972
342	241161	\N	paid	2025-04-25 00:00:00	\N	cash	60	2025-11-07 10:17:30.148	2025-11-08 09:20:40.633
109	\N	40000	paid	2025-11-06 21:32:53.658	\N	online	\N	2025-11-01 21:20:00.072	2025-11-06 16:02:59.313
277	\N	\N	due	2026-02-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
278	\N	\N	due	2026-03-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
279	\N	\N	due	2026-04-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
280	\N	\N	due	2026-05-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
281	\N	\N	due	2026-06-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
282	\N	\N	due	2026-07-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
283	\N	\N	due	2026-08-06 17:10:24.503	\N	online	\N	2025-11-06 17:10:27.16	2025-11-06 17:10:27.16
294	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
295	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
296	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
297	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
298	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
299	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
300	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
301	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
302	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
303	\N	\N	due	\N	\N	online	\N	2025-11-06 19:40:02.234	2025-11-06 19:40:02.234
284	\N	2000	due	2025-11-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
285	\N	2000	due	2025-12-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
286	\N	2000	due	2026-01-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
287	\N	2000	due	2026-02-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
288	\N	2000	due	2026-03-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
289	\N	2000	due	2026-04-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
290	\N	2000	due	2026-05-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
291	\N	2000	due	2026-06-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
292	\N	2000	due	2026-07-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
293	\N	2000	due	2026-08-06 19:37:21.76	\N	online	\N	2025-11-06 19:37:22.032	2025-11-06 19:37:22.032
264	20000	\N	paid	2025-11-06 18:30:00	https://continentalimages.s3.ap-south-1.amazonaws.com/payment-proofs/1762449994619-79911dfeb5f39b10c6ba8121b925edb3.jpg	cash	\N	2025-11-06 17:08:26.462	2025-11-06 17:27:11.425
265	10000	\N	due	2025-11-07 00:29:55.506	https://continentalimages.s3.ap-south-1.amazonaws.com/payment-proofs/1762455672728-dc76d9b501f8a5e53c72f638e6539ca0.jpg	online	\N	2025-11-06 17:08:26.462	2025-11-06 19:01:24.282
174	\N	20000	due	2026-07-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
175	\N	20000	due	2026-08-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
176	\N	20000	due	2026-09-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
177	\N	20000	due	2026-10-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
178	\N	20000	due	2026-11-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
179	\N	20000	due	2026-12-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
180	\N	20000	due	2027-01-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
181	\N	20000	due	2027-02-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
182	\N	20000	due	2027-03-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
183	\N	20000	due	2027-04-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
184	\N	20000	due	2027-05-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
185	\N	20000	due	2027-06-05 22:21:23.851	\N	online	\N	2025-11-05 22:21:24.364	2025-11-05 22:21:24.364
166	\N	30000	paid	2025-11-06 21:34:21.336	\N	online	\N	2025-11-05 22:21:24.364	2025-11-06 16:04:26.623
307	\N	\N	due	\N	\N	online	59	2025-11-07 09:38:09.309	2025-11-07 09:38:09.309
309	\N	\N	due	\N	\N	online	59	2025-11-07 09:38:09.309	2025-11-07 09:38:09.309
311	\N	\N	due	\N	\N	online	59	2025-11-07 09:38:09.309	2025-11-07 09:38:09.309
313	\N	\N	due	\N	\N	online	59	2025-11-07 09:38:09.309	2025-11-07 09:38:09.309
315	\N	\N	due	\N	\N	online	59	2025-11-07 09:38:09.309	2025-11-07 09:38:09.309
317	\N	\N	due	\N	\N	online	59	2025-11-07 09:38:09.309	2025-11-07 09:38:09.309
304	297300	\N	paid	2023-05-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:40:16.948
306	297300	\N	paid	2023-05-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:41:18.811
308	297300	\N	paid	2024-01-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:42:18.348
310	148650	\N	paid	2024-04-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:43:20.853
312	148650	\N	paid	2024-07-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:44:10.704
314	148650	\N	paid	2024-10-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:45:01.718
316	148650	\N	paid	2025-01-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:45:51.432
305	148650	\N	paid	2025-04-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:46:23.435
318	148650	\N	paid	2025-07-15 00:00:00	\N	cheque	59	2025-11-07 09:38:09.309	2025-11-07 09:46:58.472
319	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
320	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
321	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
322	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
323	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
324	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
325	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
326	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
327	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
328	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
329	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
330	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
331	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
332	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
333	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
1354	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1355	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1356	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1357	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1358	\N	\N	due	\N	\N	online	90	2025-11-11 08:36:01.893	2025-11-11 08:36:01.893
1401	104703	\N	paid	2024-09-26 00:00:00	\N	cash	92	2025-11-11 08:54:51.612	2025-11-11 08:55:32.502
1359	104703	\N	paid	2024-09-26 00:00:00	\N	cash	91	2025-11-11 08:45:53.606	2025-11-11 08:48:26.034
1360	4790	\N	paid	2024-11-15 00:00:00	\N	cash	91	2025-11-11 08:45:53.606	2025-11-11 08:48:59.551
1361	21345	\N	paid	2024-11-08 00:00:00	\N	cash	91	2025-11-11 08:45:53.606	2025-11-11 08:49:50.427
1364	392521	\N	paid	2024-12-12 00:00:00	\N	cash	91	2025-11-11 08:45:53.606	2025-11-11 08:50:18.727
1366	102918	\N	paid	2025-10-29 00:00:00	\N	cash	91	2025-11-11 08:45:53.606	2025-11-11 08:50:41.578
1403	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1405	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1407	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1409	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1410	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1411	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1412	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1413	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1414	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1415	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1416	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1417	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1418	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1402	26135	\N	paid	2024-11-08 00:00:00	\N	cash	92	2025-11-11 08:54:51.612	2025-11-11 08:56:00.999
1404	392521	\N	paid	2024-12-12 00:00:00	\N	cash	92	2025-11-11 08:54:51.612	2025-11-11 08:56:32.207
1406	102918	\N	paid	2025-10-29 00:00:00	\N	cash	92	2025-11-11 08:54:51.612	2025-11-11 08:56:57.154
1420	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1408	104703	\N	paid	2025-10-27 00:00:00	\N	cash	92	2025-11-11 08:54:51.612	2025-11-13 19:27:31.751
346	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
347	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
348	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
349	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
350	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
351	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
352	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
353	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
354	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
355	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
356	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
357	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
358	\N	\N	due	\N	\N	online	60	2025-11-07 10:17:30.148	2025-11-07 10:17:30.148
1389	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
360	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
403	91376	\N	paid	2024-12-19 00:00:00	\N	cash	62	2025-11-07 10:29:25.205	2025-11-14 07:33:55.137
362	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
364	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
366	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
367	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
368	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
369	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
370	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
371	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
372	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
373	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
374	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
375	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
376	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
377	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
378	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
379	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
380	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
381	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
382	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
383	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
384	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
385	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
386	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
387	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
388	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
389	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
390	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
391	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
392	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
393	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
394	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
395	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
396	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
397	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
398	\N	\N	due	\N	\N	online	61	2025-11-07 10:22:17.225	2025-11-07 10:22:17.225
400	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
402	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
404	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
406	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
407	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
408	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
409	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
410	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
411	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
412	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
413	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
414	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
415	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
416	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
417	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
418	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
419	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
420	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
421	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
422	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
423	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
424	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
425	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
426	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
427	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
428	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
429	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
430	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
431	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
432	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
433	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
434	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
435	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
436	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
437	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
438	\N	\N	due	\N	\N	online	62	2025-11-07 10:29:25.205	2025-11-07 10:29:25.205
440	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
442	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
444	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
446	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
448	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
449	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
450	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
451	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
452	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
453	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
454	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
455	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
456	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
457	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
458	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
459	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
460	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
461	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
462	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
463	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
464	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
465	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
363	335556	\N	paid	2025-04-21 00:00:00	\N	cheque	61	2025-11-07 10:22:17.225	2025-11-07 12:16:36.228
365	102918	\N	paid	2025-10-29 00:00:00	\N	cheque	61	2025-11-07 10:22:17.225	2025-11-07 12:17:20.347
443	46790	\N	paid	2025-02-21 00:00:00	\N	cash	63	2025-11-07 10:33:54.014	2025-11-08 08:56:39.245
445	197350	\N	paid	2025-06-24 00:00:00	\N	cash	63	2025-11-07 10:33:54.014	2025-11-08 08:57:17.409
447	102918	\N	paid	2025-10-29 00:00:00	\N	cash	63	2025-11-07 10:33:54.014	2025-11-08 08:57:42.102
405	102918	\N	paid	2025-10-29 00:00:00	\N	cash	62	2025-11-07 10:29:25.205	2025-11-08 09:12:38.376
401	237512	\N	paid	2025-04-25 00:00:00	\N	cash	62	2025-11-07 10:29:25.205	2025-11-08 09:11:50.591
466	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
467	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
468	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
469	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
470	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
471	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
472	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
473	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
474	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
475	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
476	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
477	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
478	\N	\N	due	\N	\N	online	63	2025-11-07 10:33:54.014	2025-11-07 10:33:54.014
1329	104703	\N	paid	2024-09-26 00:00:00	\N	cash	90	2025-11-11 08:36:01.893	2025-11-11 08:37:42.224
480	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
482	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
484	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
486	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
519	93218	\N	paid	2024-12-19 00:00:00	\N	cash	65	2025-11-07 10:52:40.059	2025-11-14 07:27:26.819
488	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
489	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
490	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
491	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
492	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
493	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
494	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
495	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
496	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
497	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
498	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
499	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
500	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
501	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
502	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
503	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
504	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
505	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
506	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
507	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
508	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
509	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
510	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
511	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
512	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
513	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
514	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
515	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
516	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
517	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
518	\N	\N	due	\N	\N	online	64	2025-11-07 10:37:06.906	2025-11-07 10:37:06.906
520	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
522	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
524	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
526	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
528	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
530	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
531	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
532	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
533	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
534	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
535	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
536	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
537	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
538	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
539	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
540	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
541	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
542	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
543	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
544	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
545	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
546	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
547	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
548	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
549	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
550	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
551	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
552	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
553	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
554	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
555	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
556	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
557	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
558	\N	\N	due	\N	\N	online	65	2025-11-07 10:52:40.059	2025-11-07 10:52:40.059
560	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
562	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
564	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
566	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
568	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
570	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
571	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
572	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
573	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
574	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
575	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
576	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
577	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
578	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
579	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
580	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
581	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
582	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
583	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
561	212500	\N	paid	2025-02-06 00:00:00	\N	cash	66	2025-11-07 10:54:54.469	2025-11-08 08:32:51.725
563	47606	\N	paid	2025-02-06 00:00:00	\N	cash	66	2025-11-07 10:54:54.469	2025-11-08 08:33:35.979
567	100000	\N	paid	2025-04-09 00:00:00	\N	cheque	66	2025-11-07 10:54:54.469	2025-11-08 08:35:11.78
569	102918	\N	paid	2025-10-29 00:00:00	\N	cheque	66	2025-11-07 10:54:54.469	2025-11-08 08:35:52.829
521	212500	\N	paid	2025-02-21 00:00:00	\N	cash	65	2025-11-07 10:52:40.059	2025-11-08 08:47:26.943
525	11795	\N	paid	2025-02-21 00:00:00	\N	cheque	65	2025-11-07 10:52:40.059	2025-11-08 08:48:33.477
527	205650	\N	paid	2025-06-18 00:00:00	\N	cash	65	2025-11-07 10:52:40.059	2025-11-08 08:49:12.161
529	102918	\N	paid	2025-10-29 00:00:00	\N	cash	65	2025-11-07 10:52:40.059	2025-11-08 08:49:46.938
481	212500	\N	paid	2025-02-21 00:00:00	\N	cheque	64	2025-11-07 10:37:06.906	2025-11-08 08:52:23.736
483	210924	\N	paid	2025-02-21 00:00:00	\N	cheque	64	2025-11-07 10:37:06.906	2025-11-08 08:53:02.769
485	33216	\N	paid	2025-03-03 00:00:00	\N	cash	64	2025-11-07 10:37:06.906	2025-11-08 08:53:36.332
584	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
585	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
586	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
587	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
588	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
589	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
590	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
591	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
592	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
593	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
594	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
595	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
596	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
597	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
598	\N	\N	due	\N	\N	online	66	2025-11-07 10:54:54.469	2025-11-07 10:54:54.469
1333	104435	\N	paid	2024-12-27 00:00:00	\N	cash	90	2025-11-11 08:36:01.893	2025-11-11 08:39:02.416
600	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
602	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
604	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
606	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
692	100000	\N	paid	2025-09-19 00:00:00	\N	cash	69	2025-11-07 11:27:15.985	2025-11-13 12:12:18.926
608	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
609	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
610	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
611	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
612	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
613	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
614	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
615	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
616	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
617	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
618	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
619	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
620	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
621	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
622	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
623	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
624	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
625	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
626	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
627	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
628	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
629	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
630	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
631	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
632	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
633	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
634	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
635	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
636	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
637	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
638	\N	\N	due	\N	\N	online	67	2025-11-07 10:56:50.936	2025-11-07 10:56:50.936
198	1348220	\N	paid	2024-07-05 00:00:00	\N	cheque	48	2025-11-06 09:34:25.764	2025-11-07 11:19:10.688
640	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
642	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
644	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
647	100000	\N	paid	2025-09-19 00:00:00	\N	cash	68	2025-11-07 11:24:39.938	2025-11-13 12:13:42.26
646	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
648	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
650	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
651	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
652	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
653	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
654	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
655	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
656	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
657	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
658	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
659	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
660	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
661	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
662	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
663	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
664	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
665	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
666	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
667	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
668	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
669	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
670	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
671	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
672	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
673	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
674	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
675	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
676	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
677	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
678	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
679	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
680	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
681	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
682	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
683	\N	\N	due	\N	\N	online	68	2025-11-07 11:24:39.938	2025-11-07 11:24:39.938
685	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
649	353310	\N	paid	2025-10-29 00:00:00	\N	cash	68	2025-11-07 11:24:39.938	2025-11-13 12:13:56.916
687	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
689	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
691	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
693	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
695	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
696	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
697	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
698	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
699	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
700	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
701	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
601	212500	\N	paid	2025-02-06 00:00:00	\N	cash	67	2025-11-07 10:56:50.936	2025-11-08 07:34:54.906
603	112281	\N	paid	2025-02-06 00:00:00	\N	cash	67	2025-11-07 10:56:50.936	2025-11-08 07:35:37.528
605	141075	\N	paid	2025-02-06 00:00:00	\N	cash	67	2025-11-07 10:56:50.936	2025-11-08 07:36:16.219
643	30560	\N	paid	2025-03-05 00:00:00	\N	cash	68	2025-11-07 11:24:39.938	2025-11-08 20:50:21.717
641	591680	\N	paid	2024-03-15 00:00:00	\N	cash	68	2025-11-07 11:24:39.938	2025-11-08 09:29:32.229
688	30560	\N	paid	2025-03-05 00:00:00	\N	cash	69	2025-11-07 11:27:15.985	2025-11-08 20:53:52.939
684	124440	\N	paid	2024-03-15 00:00:00	\N	cash	69	2025-11-07 11:27:15.985	2025-11-08 09:34:03.969
639	124440	\N	paid	2024-03-15 00:00:00	\N	cash	68	2025-11-07 11:24:39.938	2025-11-08 20:49:04.482
702	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
703	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
704	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
705	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
706	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
707	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
708	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
709	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
710	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
711	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
712	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
713	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
714	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
715	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
716	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
717	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
718	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
719	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
720	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
721	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
722	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
723	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
724	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
725	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
726	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
727	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
728	\N	\N	due	\N	\N	online	69	2025-11-07 11:27:15.985	2025-11-07 11:27:15.985
361	121124	\N	paid	2024-12-19 00:00:00	\N	cheque	61	2025-11-07 10:22:17.225	2025-11-07 12:11:48.082
607	102918	\N	paid	2025-10-29 00:00:00	\N	cheque	67	2025-11-07 10:56:50.936	2025-11-08 07:37:05.838
565	100000	\N	paid	2025-04-09 00:00:00	\N	cash	66	2025-11-07 10:54:54.469	2025-11-08 08:34:27.223
523	35806	\N	paid	2025-02-21 00:00:00	\N	cash	65	2025-11-07 10:52:40.059	2025-11-08 08:48:03.717
487	102918	\N	paid	2025-10-29 00:00:00	\N	cash	64	2025-11-07 10:37:06.906	2025-11-08 08:54:04.167
441	212500	\N	paid	2025-02-21 00:00:00	\N	cheque	63	2025-11-07 10:33:54.014	2025-11-08 08:56:02.307
399	212500	\N	paid	2024-12-19 00:00:00	\N	cheque	62	2025-11-07 10:29:25.205	2025-11-08 09:11:21.854
336	212500	\N	paid	2025-12-19 00:00:00	\N	cash	60	2025-11-07 10:17:30.148	2025-11-08 09:16:40.598
344	102918	\N	paid	2025-10-29 00:00:00	\N	cash	60	2025-11-07 10:17:30.148	2025-11-08 09:21:24.11
686	591680	\N	paid	2024-03-15 00:00:00	\N	cash	69	2025-11-07 11:27:15.985	2025-11-08 09:34:51.073
599	93218	\N	paid	2024-12-19 00:00:00	\N	cash	67	2025-11-07 10:56:50.936	2025-11-14 07:22:44.67
645	200000	\N	paid	2025-06-26 00:00:00	\N	cheque	68	2025-11-07 11:24:39.938	2025-11-13 12:13:28.85
730	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
732	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
734	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
735	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
736	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
737	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
738	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
739	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
740	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
741	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
742	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
743	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
744	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
745	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
746	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
747	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
748	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
749	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
750	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
751	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
752	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
753	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
754	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
755	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
756	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
757	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
758	\N	\N	due	\N	\N	online	70	2025-11-08 21:28:48.797	2025-11-08 21:28:48.797
760	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
762	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
694	353310	\N	paid	2025-10-29 00:00:00	\N	cash	69	2025-11-07 11:27:15.985	2025-11-13 12:12:43.165
764	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
766	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
767	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
768	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
769	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
770	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
771	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
772	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
773	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
774	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
775	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
776	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
777	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
778	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
779	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
780	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
781	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
782	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
783	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
784	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
785	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
786	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
787	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
788	\N	\N	due	\N	\N	online	71	2025-11-08 21:38:57.944	2025-11-08 21:38:57.944
790	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
792	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
479	91376	\N	paid	2024-12-19 00:00:00	\N	cash	64	2025-11-07 10:37:06.906	2025-11-14 07:29:19.064
794	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
796	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
797	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
798	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
799	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
800	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
801	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
802	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
761	542470	\N	paid	2024-06-21 00:00:00	\N	cash	71	2025-11-08 21:38:57.944	2025-11-10 09:45:18.359
765	102919	\N	paid	2025-10-28 00:00:00	\N	cash	71	2025-11-08 21:38:57.944	2025-11-10 09:48:32.888
789	108513	\N	paid	2024-06-21 00:00:00	\N	cash	72	2025-11-09 19:09:26.943	2025-11-10 09:50:08.593
791	542470	\N	paid	2024-06-21 00:00:00	\N	cash	72	2025-11-09 19:09:26.943	2025-11-10 09:50:41.483
359	91376	\N	paid	2024-12-19 00:00:00	\N	cheque	61	2025-11-07 10:22:17.225	2025-11-14 11:33:11.646
729	108476	\N	paid	2024-03-21 00:00:00	\N	cash	70	2025-11-08 21:28:48.797	2025-11-10 10:05:51.573
731	542380	\N	paid	2024-06-21 00:00:00	\N	cash	70	2025-11-08 21:28:48.797	2025-11-10 10:06:23.023
795	102918	\N	paid	2025-10-28 00:00:00	\N	cash	72	2025-11-09 19:09:26.943	2025-11-10 10:14:04.578
803	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
804	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
805	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
806	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
807	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
808	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
809	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
810	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
811	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
812	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
813	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
814	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
815	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
816	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
817	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
818	\N	\N	due	\N	\N	online	72	2025-11-09 19:09:26.943	2025-11-09 19:09:26.943
820	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
822	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
824	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
826	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
827	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
828	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
829	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
830	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
831	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
832	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
833	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
834	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
835	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
836	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
837	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
838	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
839	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
840	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
841	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
842	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
843	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
844	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
845	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
846	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
847	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
848	\N	\N	due	\N	\N	online	73	2025-11-09 19:26:30.864	2025-11-09 19:26:30.864
850	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
852	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
854	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
855	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
856	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
857	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
858	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
859	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
860	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
861	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
862	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
863	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
864	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
865	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
866	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
867	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
868	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
869	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
870	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
871	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
872	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
873	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
874	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
875	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
876	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
877	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
878	\N	\N	due	\N	\N	online	74	2025-11-09 19:38:33.856	2025-11-09 19:38:33.856
880	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
882	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
884	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
886	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
887	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
888	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
889	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
890	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
891	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
892	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
893	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
894	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
895	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
896	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
897	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
898	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
899	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
900	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
901	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
902	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
903	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
904	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
905	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
906	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
907	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
908	\N	\N	due	\N	\N	online	75	2025-11-09 20:00:25.078	2025-11-09 20:00:25.078
910	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
912	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
914	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
916	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
917	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
918	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
919	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
920	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
921	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
922	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
883	352547	\N	paid	2025-08-13 00:00:00	\N	cash	75	2025-11-09 20:00:25.078	2025-11-10 09:35:22.842
885	102918	\N	paid	2025-10-28 00:00:00	\N	cash	75	2025-11-09 20:00:25.078	2025-11-10 09:35:52.961
819	108513	\N	paid	2024-06-21 00:00:00	\N	cash	73	2025-11-09 19:26:30.864	2025-11-10 09:37:22.415
823	352767	\N	paid	2025-08-13 00:00:00	\N	cash	73	2025-11-09 19:26:30.864	2025-11-10 09:39:13.654
825	102918	\N	paid	2025-10-28 00:00:00	\N	cash	73	2025-11-09 19:26:30.864	2025-11-10 09:39:36.709
853	102919	\N	paid	2025-10-28 00:00:00	\N	cash	74	2025-11-09 19:38:33.856	2025-11-10 09:57:04.404
909	108476	\N	paid	2024-06-21 00:00:00	\N	cash	76	2025-11-09 20:14:38.594	2025-11-10 09:59:59.322
915	102919	\N	paid	2025-10-28 00:00:00	\N	cash	76	2025-11-09 20:14:38.594	2025-11-10 10:02:19.946
911	542380	\N	paid	2024-06-21 00:00:00	\N	cash	76	2025-11-09 20:14:38.594	2025-11-10 10:01:22.821
849	108513	\N	paid	2024-03-21 00:00:00	\N	cash	74	2025-11-09 19:38:33.856	2025-11-10 10:12:16.353
923	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
924	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
925	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
926	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
927	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
928	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
929	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
930	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
931	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
932	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
933	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
934	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
935	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
936	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
937	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
938	\N	\N	due	\N	\N	online	76	2025-11-09 20:14:38.594	2025-11-09 20:14:38.594
940	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
942	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
944	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
1362	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
946	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
947	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
948	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
949	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
950	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
951	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
952	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
953	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
954	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
955	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
956	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
957	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
958	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
959	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
960	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
961	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
962	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
963	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
964	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
965	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
966	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
967	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
968	\N	\N	due	\N	\N	online	77	2025-11-09 20:19:15.221	2025-11-09 20:19:15.221
970	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
972	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
974	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
976	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
977	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
978	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
979	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
980	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
981	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
982	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
983	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
984	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
985	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
986	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
987	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
988	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
989	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
990	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
991	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
992	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
993	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
994	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
995	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
996	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
997	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
998	\N	\N	due	\N	\N	online	78	2025-11-09 20:35:42.866	2025-11-09 20:35:42.866
1000	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1002	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1004	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1006	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1008	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1009	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1010	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1011	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1012	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1013	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1014	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1015	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1016	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1017	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1018	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1019	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1020	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1021	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1022	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1023	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1024	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1025	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1026	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1027	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1028	\N	\N	due	\N	\N	online	79	2025-11-09 21:08:43.069	2025-11-09 21:08:43.069
1030	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1032	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1034	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1036	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1038	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1040	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1042	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1033	116600	\N	paid	2024-09-02 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:21:15.92
1035	200252	\N	paid	2024-09-17 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:21:57.004
1037	199800	\N	paid	2024-09-17 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:22:31.05
1041	102918	\N	paid	2025-10-29 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:23:17.83
999	152640	\N	paid	2024-12-27 00:00:00	\N	cash	79	2025-11-09 21:08:43.069	2025-11-10 08:22:59.865
1001	483320	\N	paid	2024-12-27 00:00:00	\N	cash	79	2025-11-09 21:08:43.069	2025-11-10 08:23:29.766
1005	19880	\N	paid	2025-10-29 00:00:00	\N	cash	79	2025-11-09 21:08:43.069	2025-11-10 08:24:42.322
1007	102918	\N	paid	2025-10-29 00:00:00	\N	cash	79	2025-11-09 21:08:43.069	2025-11-10 08:25:10.498
969	542470	\N	paid	2024-06-21 00:00:00	\N	cash	78	2025-11-09 20:35:42.866	2025-11-10 09:13:47.25
971	352767	\N	paid	2025-08-13 00:00:00	\N	cash	78	2025-11-09 20:35:42.866	2025-11-10 09:14:20.512
939	108513	\N	paid	2024-06-21 00:00:00	\N	cash	77	2025-11-09 20:19:15.221	2025-11-10 09:21:52.587
941	542470	\N	paid	2024-06-21 00:00:00	\N	cash	77	2025-11-09 20:19:15.221	2025-11-10 09:25:38.082
943	352767	\N	paid	2025-08-13 00:00:00	\N	cash	77	2025-11-09 20:19:15.221	2025-11-10 09:26:15.398
975	108513	\N	paid	2024-06-21 00:00:00	\N	cash	78	2025-11-09 20:35:42.866	2025-11-10 09:28:33.627
1044	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1045	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1046	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1047	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1048	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1049	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1050	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1051	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1052	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1053	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1054	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1055	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1056	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1057	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1058	\N	\N	due	\N	\N	online	80	2025-11-10 06:44:53.601	2025-11-10 06:44:53.601
1029	150600	\N	paid	2024-06-19 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:19:32.902
1031	39468	\N	paid	2024-05-24 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:20:12.196
1039	196800	\N	paid	2024-09-23 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:22:54.833
1043	2147	\N	paid	2024-09-23 00:00:00	\N	cash	80	2025-11-10 06:44:53.601	2025-11-10 07:24:00.835
1003	260000	\N	paid	2025-01-10 00:00:00	\N	cash	79	2025-11-09 21:08:43.069	2025-11-10 08:24:12.224
973	102918	\N	paid	2025-10-28 00:00:00	\N	cash	78	2025-11-09 20:35:42.866	2025-11-10 09:16:45.345
945	102919	\N	paid	2025-10-28 00:00:00	\N	cash	77	2025-11-09 20:19:15.221	2025-11-10 09:26:58.934
879	108476	\N	paid	2024-06-21 00:00:00	\N	cash	75	2025-11-09 20:00:25.078	2025-11-10 09:34:00.985
881	542380	\N	paid	2024-06-21 00:00:00	\N	cash	75	2025-11-09 20:00:25.078	2025-11-10 09:34:28.398
821	542470	\N	paid	2024-06-21 00:00:00	\N	cash	73	2025-11-09 19:26:30.864	2025-11-10 09:38:44.436
759	108513	\N	paid	2024-06-21 00:00:00	\N	cash	71	2025-11-08 21:38:57.944	2025-11-10 09:44:14.728
763	352767	\N	paid	2025-08-13 00:00:00	\N	cash	71	2025-11-08 21:38:57.944	2025-11-10 09:47:32.356
851	542470	\N	paid	2024-06-21 00:00:00	\N	cash	74	2025-11-09 19:38:33.856	2025-11-10 09:56:24.748
913	352547	\N	paid	2024-08-13 00:00:00	\N	cash	76	2025-11-09 20:14:38.594	2025-11-10 10:01:52.847
733	102918	\N	paid	2025-10-28 00:00:00	\N	cash	70	2025-11-08 21:28:48.797	2025-11-10 10:06:46.575
793	352740	\N	paid	2025-08-18 00:00:00	\N	cash	72	2025-11-09 19:09:26.943	2025-11-10 10:16:52.092
1060	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1062	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1064	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1066	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1067	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1068	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1069	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1070	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1071	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1072	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1073	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1074	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1075	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1076	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1077	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1078	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1079	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1080	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1081	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1082	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1083	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1084	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1085	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1086	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1087	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1088	\N	\N	due	\N	\N	online	81	2025-11-10 10:22:51.124	2025-11-10 10:22:51.124
1059	108476	\N	paid	2024-03-21 00:00:00	\N	cash	81	2025-11-10 10:22:51.124	2025-11-10 10:28:07.79
1061	542380	\N	paid	2024-06-21 00:00:00	\N	cash	81	2025-11-10 10:22:51.124	2025-11-10 10:28:35.339
1063	352547	\N	paid	2025-08-13 00:00:00	\N	cash	81	2025-11-10 10:22:51.124	2025-11-10 10:29:00.144
1065	102918	\N	paid	2025-10-28 00:00:00	\N	cash	81	2025-11-10 10:22:51.124	2025-11-10 10:29:45.681
1090	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1092	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1094	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1096	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1098	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1100	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1102	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1104	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1106	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1107	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1108	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1109	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1110	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1111	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1112	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1113	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1114	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1115	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1116	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1117	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1118	\N	\N	due	\N	\N	online	82	2025-11-10 10:48:10.614	2025-11-10 10:48:10.614
1089	164680	\N	paid	2024-05-24 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:48:51.952
1091	28550	\N	paid	2024-08-16 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:49:19.848
1093	85280	\N	paid	2024-09-02 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:49:46.878
1095	200400	\N	paid	2024-09-17 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:50:15.444
1119	165760	\N	paid	2024-05-27 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:12:20.164
1097	109300	\N	paid	2024-09-20 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:51:30.514
1099	199600	\N	paid	2024-09-20 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:52:12.698
1101	200270	\N	paid	2024-09-20 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:52:44.247
1103	30	\N	paid	2024-09-20 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:53:09.312
1105	102918	\N	paid	2025-10-29 00:00:00	\N	cash	82	2025-11-10 10:48:10.614	2025-11-10 10:53:41.406
1121	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1123	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1125	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1127	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1129	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1131	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1133	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1134	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1120	57200	\N	paid	2024-08-16 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:12:45.693
1122	184200	\N	paid	2024-09-06 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:13:11.752
1124	200100	\N	paid	2024-09-12 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:13:54.103
1126	200200	\N	paid	2024-09-17 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:14:18.616
1128	187100	\N	paid	2024-09-17 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:14:44.928
1132	102918	\N	paid	2025-08-29 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:17:04.174
1363	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1130	12900	\N	paid	2024-09-17 00:00:00	\N	cash	83	2025-11-10 11:02:25.85	2025-11-10 11:16:01.824
1365	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1135	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1136	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1137	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1138	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1139	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1140	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1141	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1142	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1143	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1144	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1145	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1146	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1147	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1148	\N	\N	due	\N	\N	online	83	2025-11-10 11:02:25.85	2025-11-10 11:02:25.85
1150	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1152	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1154	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1156	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1158	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1160	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1162	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1164	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1166	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1167	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1168	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1169	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1170	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1171	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1172	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1173	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1174	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1175	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1176	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1177	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1178	\N	\N	due	\N	\N	online	84	2025-11-10 12:46:29.919	2025-11-10 12:46:29.919
1149	474228	\N	paid	2024-05-07 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:48:28.882
1151	1786193	\N	paid	2024-07-04 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:49:00.882
1153	110000	\N	paid	2025-01-13 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:49:31.714
1155	100000	\N	paid	2025-02-14 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:50:09.236
1157	100000	\N	paid	2025-03-05 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:50:40.77
1159	100000	\N	paid	2025-03-14 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:51:06.978
1161	70000	\N	paid	2025-03-24 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:51:32.201
1163	100000	\N	paid	2025-03-24 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:51:59.924
1165	2500000	\N	paid	2025-10-23 00:00:00	\N	cash	84	2025-11-10 12:46:29.919	2025-11-10 12:52:27.034
1180	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1182	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1184	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1186	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1188	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1190	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1192	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1194	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1196	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1198	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1200	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1201	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1202	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1203	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1204	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1205	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1206	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1207	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1208	\N	\N	due	\N	\N	online	85	2025-11-10 12:59:42.962	2025-11-10 12:59:42.962
1179	487760	\N	paid	2024-04-03 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:02:44.094
1181	2413629	\N	paid	2024-09-02 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:03:17.753
1183	243000	\N	paid	2024-03-28 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:03:49.105
1185	963815	\N	paid	2024-04-02 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:04:24.996
1187	1206814	\N	paid	2024-04-24 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:04:55.905
1209	89454	\N	paid	2024-09-26 00:00:00	\N	cash	86	2025-11-11 08:03:11.607	2025-11-11 08:04:50.2
1191	61290	\N	paid	2024-11-05 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:06:12.898
1189	28992	\N	paid	2024-10-29 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:06:44.489
1193	91672	\N	paid	2025-01-08 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:07:37.435
1195	100000	\N	paid	2025-07-25 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:08:22.47
1210	40000	\N	paid	2024-10-15 00:00:00	\N	cash	86	2025-11-11 08:03:11.607	2025-11-11 08:05:33.995
1197	100000	\N	paid	2025-07-28 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:08:49.628
1199	2500000	\N	paid	2025-10-23 00:00:00	\N	cash	85	2025-11-10 12:59:42.962	2025-11-10 13:09:22.421
1212	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1213	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1215	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1218	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1220	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1221	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1222	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1223	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1224	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1225	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1226	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1211	317777	\N	paid	2024-12-12 00:00:00	\N	cash	86	2025-11-11 08:03:11.607	2025-11-11 08:06:04.638
1214	102918	\N	paid	2025-10-29 00:00:00	\N	cash	86	2025-11-11 08:03:11.607	2025-11-11 08:07:15.775
1367	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1369	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1370	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1371	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1372	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1373	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1374	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1375	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1376	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1377	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1378	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1379	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1380	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1381	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1382	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1383	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1384	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1385	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1386	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1216	60000	\N	paid	2025-10-24 00:00:00	\N	cash	86	2025-11-11 08:03:11.607	2025-11-13 19:37:42.899
1217	11818	\N	paid	2025-10-27 00:00:00	\N	cash	86	2025-11-11 08:03:11.607	2025-11-13 19:38:24.192
1219	17676	\N	paid	2025-10-28 00:00:00	\N	cash	86	2025-11-11 08:03:11.607	2025-11-13 19:38:52.449
1227	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1228	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1229	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1230	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1231	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1232	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1233	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1234	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1235	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1236	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1237	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1238	\N	\N	due	\N	\N	online	86	2025-11-11 08:03:11.607	2025-11-11 08:03:11.607
1240	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1242	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1244	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1246	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1248	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1250	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1251	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1252	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1253	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1254	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1255	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1256	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1257	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1258	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1259	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1260	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1261	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1262	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1263	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1264	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1265	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1266	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1267	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1268	\N	\N	due	\N	\N	online	87	2025-11-11 08:10:51.219	2025-11-11 08:10:51.219
1239	89454	\N	paid	2024-09-19 00:00:00	\N	cash	87	2025-11-11 08:10:51.219	2025-11-11 08:14:02.952
1241	10505	\N	paid	2024-10-15 00:00:00	\N	cash	87	2025-11-11 08:10:51.219	2025-11-11 08:14:34.119
1243	11818	\N	paid	2024-11-08 00:00:00	\N	cash	87	2025-11-11 08:10:51.219	2025-11-11 08:15:02.924
1245	335454	\N	paid	2024-12-12 00:00:00	\N	cash	87	2025-11-11 08:10:51.219	2025-11-11 08:15:28.315
1247	102918	\N	paid	2025-10-29 00:00:00	\N	cash	87	2025-11-11 08:10:51.219	2025-11-11 08:15:51.896
1270	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1272	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1274	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1276	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1278	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1280	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1282	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1283	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1284	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1285	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1286	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1287	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1288	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1289	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1290	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1291	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1292	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1293	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1294	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1295	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1296	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1297	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1298	\N	\N	due	\N	\N	online	88	2025-11-11 08:19:11.174	2025-11-11 08:19:11.174
1269	89493	\N	paid	2024-10-15 00:00:00	\N	cash	88	2025-11-11 08:19:11.174	2025-11-11 08:20:12.756
1271	10466	\N	paid	2024-09-19 00:00:00	\N	cash	88	2025-11-11 08:19:11.174	2025-11-11 08:20:55.413
1273	11867	\N	paid	2024-11-08 00:00:00	\N	cash	88	2025-11-11 08:19:11.174	2025-11-11 08:21:26.555
1275	335601	\N	paid	2024-12-12 00:00:00	\N	cash	88	2025-11-11 08:19:11.174	2025-11-11 08:22:15.911
1277	102918	\N	paid	2025-10-29 00:00:00	\N	cash	88	2025-11-11 08:19:11.174	2025-11-11 08:22:50.502
1300	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1302	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1304	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1306	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1308	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1310	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1312	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1313	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1314	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1315	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1316	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1317	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1318	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1319	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1320	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1321	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1322	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1323	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1324	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1325	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1326	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1327	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1328	\N	\N	due	\N	\N	online	89	2025-11-11 08:27:24.72	2025-11-11 08:27:24.72
1299	89493	\N	paid	2024-09-19 00:00:00	\N	cash	89	2025-11-11 08:27:24.72	2025-11-11 08:28:22.687
1301	10466	\N	paid	2024-10-15 00:00:00	\N	cash	89	2025-11-11 08:27:24.72	2025-11-11 08:28:49.097
1303	11867	\N	paid	2024-11-08 00:00:00	\N	cash	89	2025-11-11 08:27:24.72	2025-11-11 08:29:14.35
1305	335601	\N	paid	2024-12-12 00:00:00	\N	cash	89	2025-11-11 08:27:24.72	2025-11-11 08:30:07.768
1307	102918	\N	paid	2025-10-29 00:00:00	\N	cash	89	2025-11-11 08:27:24.72	2025-11-11 08:30:33.353
1387	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1388	\N	\N	due	\N	\N	online	91	2025-11-11 08:45:53.606	2025-11-11 08:45:53.606
1390	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1391	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1392	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1393	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1394	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1395	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1396	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1397	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1398	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1399	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1400	\N	\N	due	\N	\N	online	92	2025-11-11 08:54:51.612	2025-11-11 08:54:51.612
1311	29533	\N	paid	2025-10-28 00:00:00	\N	cash	89	2025-11-11 08:27:24.72	2025-11-13 19:31:55.032
1279	49533	\N	paid	2025-10-27 00:00:00	\N	cash	88	2025-11-11 08:19:11.174	2025-11-13 19:33:48.548
1249	89454	\N	paid	2025-10-27 00:00:00	\N	cash	87	2025-11-11 08:10:51.219	2025-11-13 19:35:54.807
1422	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1424	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1426	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1428	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1429	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1430	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1431	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1432	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1433	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1434	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1435	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1436	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1437	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1438	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1439	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1440	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1441	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1442	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1443	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1444	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1445	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1446	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1447	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1448	\N	\N	due	\N	\N	online	93	2025-11-11 09:03:25.627	2025-11-11 09:03:25.627
1419	104703	\N	paid	2024-09-26 00:00:00	\N	cash	93	2025-11-11 09:03:25.627	2025-11-11 09:04:24.863
1421	26135	\N	paid	2024-11-08 00:00:00	\N	cash	93	2025-11-11 09:03:25.627	2025-11-11 09:04:59.936
1423	392521	\N	paid	2024-12-12 00:00:00	\N	cash	93	2025-11-11 09:03:25.627	2025-11-11 09:05:30.738
1425	102918	\N	paid	2025-10-29 00:00:00	\N	cash	93	2025-11-11 09:03:25.627	2025-11-11 09:05:55.83
1450	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1452	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1454	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1456	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1458	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1459	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1460	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1461	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1462	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1463	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1464	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1465	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1466	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1467	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1468	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1469	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1470	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1471	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1472	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1473	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1474	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1475	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1476	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1477	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1478	\N	\N	due	\N	\N	online	94	2025-11-11 09:10:50.399	2025-11-11 09:10:50.399
1449	104703	\N	paid	2024-09-26 00:00:00	\N	cash	94	2025-11-11 09:10:50.399	2025-11-11 09:11:43.587
1451	26135	\N	paid	2024-11-08 00:00:00	\N	cash	94	2025-11-11 09:10:50.399	2025-11-11 09:12:06.636
1453	392637	\N	paid	2024-12-12 00:00:00	\N	cash	94	2025-11-11 09:10:50.399	2025-11-11 09:12:31.104
1455	102918	\N	paid	2025-10-29 00:00:00	\N	cash	94	2025-11-11 09:10:50.399	2025-11-11 09:12:50.646
1480	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1482	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1484	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1486	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1488	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1489	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1490	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1491	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1492	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1493	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1494	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1495	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1496	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1497	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1498	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1499	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1500	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1501	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1502	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1503	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1504	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1505	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1506	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1507	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1508	\N	\N	due	\N	\N	online	95	2025-11-11 09:17:43.2	2025-11-11 09:17:43.2
1479	104703	\N	paid	2024-09-26 00:00:00	\N	cash	95	2025-11-11 09:17:43.2	2025-11-11 09:19:44.317
1481	26135	\N	paid	2024-11-08 00:00:00	\N	cash	95	2025-11-11 09:17:43.2	2025-11-11 09:20:05.327
1483	392637	\N	paid	2024-12-12 00:00:00	\N	cash	95	2025-11-11 09:17:43.2	2025-11-11 09:20:29.697
1485	102918	\N	paid	2025-10-29 00:00:00	\N	cash	95	2025-11-11 09:17:43.2	2025-11-11 09:20:50.336
690	200000	\N	paid	2025-06-26 00:00:00	\N	cash	69	2025-11-07 11:27:15.985	2025-11-13 12:11:50.084
1487	104703	\N	paid	2025-10-27 00:00:00	\N	cash	95	2025-11-11 09:17:43.2	2025-11-13 19:21:37.054
1457	104703	\N	paid	2025-10-27 00:00:00	\N	cash	94	2025-11-11 09:10:50.399	2025-11-13 19:24:17.294
1427	104703	\N	paid	2025-10-27 00:00:00	\N	cash	93	2025-11-11 09:03:25.627	2025-11-13 19:25:51.808
1368	104703	\N	paid	2025-10-27 00:00:00	\N	cash	91	2025-11-11 08:45:53.606	2025-11-13 19:29:16.964
1309	60000	\N	paid	2025-10-27 00:00:00	\N	cash	89	2025-11-11 08:27:24.72	2025-11-13 19:31:30.599
1281	40000	\N	paid	2025-10-28 00:00:00	\N	cash	88	2025-11-11 08:19:11.174	2025-11-13 19:34:06.583
559	93218	\N	paid	2024-12-19 00:00:00	\N	cheque	66	2025-11-07 10:54:54.469	2025-11-14 07:24:39.082
439	91376	\N	paid	2024-12-19 00:00:00	\N	cash	63	2025-11-07 10:33:54.014	2025-11-14 07:31:35.812
334	91376	\N	paid	2024-12-19 00:00:00	\N	cash	60	2025-11-07 10:17:30.148	2025-11-14 11:34:39.635
1519	\N	200000	due	2025-11-20 16:26:01.004	\N	online	\N	2025-11-20 16:26:01.264	2025-11-20 16:26:01.264
1513	\N	170000	due	2025-11-20 08:19:20.865	\N	online	\N	2025-11-20 08:19:21.107	2025-11-20 08:19:21.107
1520	\N	1	due	2026-11-20 16:26:01.004	\N	online	\N	2025-11-20 16:26:01.264	2025-11-20 16:32:38.245
1514	\N	170000	due	2026-11-20 08:19:20.865	\N	online	\N	2025-11-20 08:19:21.107	2025-11-20 08:19:21.107
1509	\N	157660	due	2025-11-20 08:02:51.768	\N	online	\N	2025-11-20 08:02:52.212	2025-11-20 08:02:52.212
1510	\N	157660	due	2026-11-20 08:02:51.768	\N	online	\N	2025-11-20 08:02:52.212	2025-11-20 08:02:52.212
1511	\N	157660	due	2027-11-20 08:02:51.768	\N	online	\N	2025-11-20 08:02:52.212	2025-11-20 08:02:52.212
1512	\N	157660	due	2028-11-20 08:02:51.768	\N	online	\N	2025-11-20 08:02:52.212	2025-11-20 08:02:52.212
1517	\N	270000	due	2025-11-20 08:29:01.811	\N	online	\N	2025-11-20 08:29:02.409	2025-11-20 08:29:02.409
1518	\N	270000	due	2026-11-20 08:29:01.811	\N	online	\N	2025-11-20 08:29:02.409	2025-11-20 08:29:02.409
1515	\N	170000	due	2027-11-20 08:19:20.865	\N	online	\N	2025-11-20 08:19:21.107	2025-11-20 08:19:21.107
1516	\N	170000	due	2028-11-20 08:19:20.865	\N	online	\N	2025-11-20 08:19:21.107	2025-11-20 08:19:21.107
1521	\N	270000	due	2025-11-20 16:42:22.877	\N	online	100	2025-11-20 16:42:23.115	2025-11-20 16:42:23.115
1522	\N	157660	due	2025-11-20 16:52:54.903	\N	online	101	2025-11-20 16:52:55.159	2025-11-20 16:52:55.159
1523	\N	170000	due	2025-11-20 16:55:54.767	\N	online	102	2025-11-20 16:55:55.261	2025-11-20 16:55:55.261
1524	\N	200000	due	2025-11-20 16:59:16.548	\N	online	103	2025-11-20 16:59:16.817	2025-11-20 16:59:16.817
1526	\N	20000	due	2025-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1626	\N	200	due	2025-11-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1627	\N	200	due	2025-12-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1628	\N	200	due	2026-01-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1629	\N	200	due	2026-02-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1630	\N	200	due	2026-03-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1631	\N	200	due	2026-04-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1632	\N	200	due	2026-05-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1633	\N	200	due	2026-06-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1634	\N	200	due	2026-07-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1635	\N	200	due	2026-08-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1636	\N	200	due	2026-09-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1637	\N	200	due	2026-10-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1638	\N	200	due	2026-11-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1639	\N	200	due	2026-12-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1640	\N	200	due	2027-01-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1641	\N	200	due	2027-02-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1642	\N	200	due	2027-03-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1643	\N	200	due	2027-04-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1644	\N	200	due	2027-05-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1645	\N	200	due	2027-06-22 17:11:44.578	\N	online	106	2025-11-22 17:11:46.655	2025-11-22 17:11:46.655
1525	\N	183000	due	2025-11-20 17:08:26.703	\N	online	\N	2025-11-20 17:08:26.924	2025-11-20 17:08:26.924
1527	\N	20000	due	2025-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1528	\N	20000	due	2026-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1529	\N	20000	due	2026-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1530	\N	20000	due	2026-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1531	\N	20000	due	2026-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1532	\N	20000	due	2026-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1533	\N	20000	due	2026-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1534	\N	20000	due	2026-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1535	\N	20000	due	2026-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1536	\N	20000	due	2026-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1537	\N	20000	due	2026-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1538	\N	20000	due	2026-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1539	\N	20000	due	2026-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1540	\N	20000	due	2027-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1541	\N	20000	due	2027-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1542	\N	20000	due	2027-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1543	\N	20000	due	2027-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1544	\N	20000	due	2027-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1545	\N	20000	due	2027-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1546	\N	20000	due	2027-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1547	\N	20000	due	2027-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1548	\N	20000	due	2027-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1549	\N	20000	due	2027-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1550	\N	20000	due	2027-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1551	\N	20000	due	2027-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1552	\N	20000	due	2028-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1553	\N	20000	due	2028-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1554	\N	20000	due	2028-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1555	\N	20000	due	2028-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1556	\N	20000	due	2028-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1557	\N	20000	due	2028-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1558	\N	20000	due	2028-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1559	\N	20000	due	2028-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1560	\N	20000	due	2028-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1561	\N	20000	due	2028-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1562	\N	20000	due	2028-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1563	\N	20000	due	2028-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1564	\N	20000	due	2029-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1565	\N	20000	due	2029-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1566	\N	20000	due	2029-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1567	\N	20000	due	2029-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1568	\N	20000	due	2029-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1569	\N	20000	due	2029-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1570	\N	20000	due	2029-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1571	\N	20000	due	2029-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1572	\N	20000	due	2029-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1573	\N	20000	due	2029-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1574	\N	20000	due	2029-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1575	\N	20000	due	2029-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1576	\N	20000	due	2030-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1577	\N	20000	due	2030-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1578	\N	20000	due	2030-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1579	\N	20000	due	2030-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1580	\N	20000	due	2030-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1581	\N	20000	due	2030-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1582	\N	20000	due	2030-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1583	\N	20000	due	2030-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1584	\N	20000	due	2030-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1585	\N	20000	due	2030-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1586	\N	20000	due	2030-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1587	\N	20000	due	2030-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1588	\N	20000	due	2031-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1589	\N	20000	due	2031-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1590	\N	20000	due	2031-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1591	\N	20000	due	2031-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1592	\N	20000	due	2031-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1593	\N	20000	due	2031-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1594	\N	20000	due	2031-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1595	\N	20000	due	2031-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1596	\N	20000	due	2031-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1597	\N	20000	due	2031-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1598	\N	20000	due	2031-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1599	\N	20000	due	2031-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1600	\N	20000	due	2032-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1601	\N	20000	due	2032-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1602	\N	20000	due	2032-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1603	\N	20000	due	2032-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1604	\N	20000	due	2032-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1605	\N	20000	due	2032-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1606	\N	20000	due	2032-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1607	\N	20000	due	2032-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1608	\N	20000	due	2032-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1609	\N	20000	due	2032-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1610	\N	20000	due	2032-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1611	\N	20000	due	2032-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1612	\N	20000	due	2033-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1613	\N	20000	due	2033-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1614	\N	20000	due	2033-03-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1615	\N	20000	due	2033-04-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1616	\N	20000	due	2033-05-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1617	\N	20000	due	2033-06-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1618	\N	20000	due	2033-07-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1619	\N	20000	due	2033-08-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1620	\N	20000	due	2033-09-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1621	\N	20000	due	2033-10-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1622	\N	20000	due	2033-11-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1623	\N	20000	due	2033-12-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1624	\N	20000	due	2034-01-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1625	\N	20000	due	2034-02-22 16:35:09.006	\N	online	\N	2025-11-22 16:35:13.826	2025-11-22 16:35:13.826
1648	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1649	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1650	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1651	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1652	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1653	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1654	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1655	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1656	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1657	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1658	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1659	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1660	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1661	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1662	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1663	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1664	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1665	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1666	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1667	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1668	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1669	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1670	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1671	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1672	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1673	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1674	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1675	\N	\N	due	\N	\N	online	107	2026-01-19 12:35:00.653	2026-01-19 12:35:00.653
1677	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1679	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1681	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1682	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1683	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1684	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1685	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1686	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1687	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1688	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1689	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1690	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1691	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1692	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1693	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1694	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1695	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1696	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1697	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1698	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1699	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1700	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1701	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1702	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1703	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1704	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1705	\N	\N	due	\N	\N	online	108	2026-01-19 12:44:27.435	2026-01-19 12:44:27.435
1707	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1709	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1710	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1711	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1712	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1713	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1714	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1715	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1716	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1717	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1718	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1719	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1720	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1721	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1722	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1723	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1724	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1708	153745	\N	paid	2025-10-03 00:00:00	\N	cash	109	2026-01-19 12:47:57.426	2026-02-17 11:39:05.973
1647	153842	\N	paid	2025-10-03 00:00:00	\N	cash	107	2026-01-19 12:35:00.653	2026-02-17 11:41:23.724
1676	206602	\N	paid	2025-10-03 00:00:00	\N	cash	108	2026-01-19 12:44:27.435	2026-02-17 11:47:06.168
1678	528444	\N	paid	2025-10-03 00:00:00	\N	cash	108	2026-01-19 12:44:27.435	2026-02-17 11:47:34.012
1725	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1726	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1727	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1728	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1729	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1730	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1731	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1732	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1733	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1734	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1735	\N	\N	due	\N	\N	online	109	2026-01-19 12:47:57.426	2026-01-19 12:47:57.426
1737	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1739	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1740	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1741	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1742	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1743	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1744	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1745	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1746	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1747	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1748	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1749	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1750	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1751	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1752	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1753	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1754	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1755	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1756	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1757	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1758	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1759	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1760	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1761	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1762	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1763	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1764	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1765	\N	\N	due	\N	\N	online	110	2026-01-19 12:50:48.509	2026-01-19 12:50:48.509
1766	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1767	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1768	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1769	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1770	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1771	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1772	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1773	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1774	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1775	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1776	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1777	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1778	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1779	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1780	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1781	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1782	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1783	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1784	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1785	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1786	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1787	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1788	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1789	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1790	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1791	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1792	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1793	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1794	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1795	\N	\N	due	\N	\N	online	111	2026-01-19 12:53:18.748	2026-01-19 12:53:18.748
1797	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1799	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1801	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1802	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1803	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1804	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1805	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1806	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1807	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1808	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1809	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1810	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1811	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1812	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1813	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1814	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1815	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1816	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1817	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1818	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1819	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1820	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1821	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1822	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1823	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1824	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1825	\N	\N	due	\N	\N	online	112	2026-01-19 13:03:41.985	2026-01-19 13:03:41.985
1826	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1827	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1828	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1829	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1830	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1831	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1832	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1833	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1834	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1835	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1836	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1837	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1838	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1839	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1840	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1841	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1842	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1843	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1844	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1796	59144	\N	paid	2025-10-03 00:00:00	\N	cash	112	2026-01-19 13:03:41.985	2026-02-17 11:35:40.776
1798	134636	\N	paid	2025-10-03 00:00:00	\N	cash	112	2026-01-19 13:03:41.985	2026-02-17 11:36:13.865
1800	131573	\N	paid	2025-11-02 00:00:00	\N	cash	112	2026-01-19 13:03:41.985	2026-02-17 11:36:42.343
1845	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1846	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1847	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1848	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1849	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1850	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1851	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1852	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1853	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1854	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
1855	\N	\N	due	\N	\N	online	113	2026-01-19 13:09:14.358	2026-01-19 13:09:14.358
128	1674504	\N	due	2026-05-01 21:16:01.781	\N	online	\N	2025-11-01 21:20:00.072	\N
129	1674504	\N	due	2026-06-01 21:16:01.781	\N	online	\N	2025-11-01 21:20:00.072	\N
122	2576160	\N	paid	2025-11-03 15:49:56.469	\N	cheque	\N	2025-11-01 21:20:00.072	2025-11-03 11:51:05.066
123	515232	\N	paid	2025-11-03 15:51:46.889	\N	online	\N	2025-11-01 21:20:00.072	2025-11-03 11:52:29.125
124	1000000	\N	paid	2025-11-03 15:52:36.914	\N	online	\N	2025-11-01 21:20:00.072	2025-11-03 11:52:48.811
125	1754140	\N	paid	2025-11-04 00:00:00	\N	online	\N	2025-11-01 21:20:00.072	2025-11-05 23:52:13.01
126	1000000	\N	due	2026-03-01 21:16:01.781	\N	online	\N	2025-11-01 21:20:00.072	2026-02-13 09:45:01.045
1857	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1859	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1861	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1863	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1864	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1865	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1866	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1867	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1868	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1869	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1870	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1871	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1872	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1873	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1874	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1875	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1876	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1877	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1878	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1879	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1880	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1881	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1882	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1883	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1884	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1885	\N	\N	due	\N	\N	online	114	2026-02-13 10:10:55.244	2026-02-13 10:10:55.244
1856	2576160	\N	paid	2026-02-13 15:54:13.944	\N	cash	114	2026-02-13 10:10:55.244	2026-02-13 11:54:51.784
1858	1000000	\N	paid	2026-02-13 15:54:59.931	\N	cash	114	2026-02-13 10:10:55.244	2026-02-13 11:55:21.281
1860	1754140	\N	paid	2026-02-13 15:56:09.479	\N	cash	114	2026-02-13 10:10:55.244	2026-02-13 11:56:37.232
1862	1000000	\N	paid	2026-02-13 15:56:39.987	\N	cash	114	2026-02-13 10:10:55.244	2026-02-13 11:57:04.673
1736	66749	\N	paid	2025-10-03 00:00:00	\N	cash	110	2026-01-19 12:50:48.509	2026-02-17 11:28:23.468
1738	153648	\N	paid	2025-10-03 00:00:00	\N	cash	110	2026-01-19 12:50:48.509	2026-02-17 11:29:02.999
1706	66788	\N	paid	2025-10-03 00:00:00	\N	cash	109	2026-01-19 12:47:57.426	2026-02-17 11:38:38.183
1646	66827	\N	paid	2025-10-03 00:00:00	\N	cash	107	2026-01-19 12:35:00.653	2026-02-17 11:40:46.974
1680	173215	\N	paid	2025-10-03 00:00:00	\N	cash	108	2026-01-19 12:44:27.435	2026-02-17 11:48:03.678
1888	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1889	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1890	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1891	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1892	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1893	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1894	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1895	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1896	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1897	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1898	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1899	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1900	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1901	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1902	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1903	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1904	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1905	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1906	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1907	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1908	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1909	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1910	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1911	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1912	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1913	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1914	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1915	\N	\N	due	\N	\N	online	115	2026-02-18 10:44:06.247	2026-02-18 10:44:06.247
1886	57963	\N	paid	2026-01-02 00:00:00	\N	cash	115	2026-02-18 10:44:06.247	2026-02-18 10:46:17.591
1887	231852	\N	paid	2026-02-16 00:00:00	\N	cash	115	2026-02-18 10:44:06.247	2026-02-18 10:46:49.052
1917	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1919	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1920	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1921	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1922	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1923	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1924	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1925	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1926	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1927	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1928	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1929	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1930	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1931	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1932	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1933	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1934	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1935	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1936	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1937	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1938	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1939	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1940	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1916	57963	\N	paid	2026-01-02 00:00:00	\N	cash	116	2026-02-18 10:50:54.277	2026-02-18 10:51:52.654
1918	231852	\N	paid	2026-02-16 00:00:00	\N	cash	116	2026-02-18 10:50:54.277	2026-02-18 10:52:26.039
1941	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1942	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1943	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1944	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1945	\N	\N	due	\N	\N	online	116	2026-02-18 10:50:54.277	2026-02-18 10:50:54.277
1947	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1949	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1951	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1952	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1953	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1954	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1955	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1956	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1957	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1958	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1959	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1960	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1961	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1962	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1963	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1964	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1965	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1966	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1967	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1968	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1969	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1970	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1971	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1972	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1973	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1974	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
1975	\N	\N	due	\N	\N	online	117	2026-02-18 10:55:19.966	2026-02-18 10:55:19.966
2006	57605	\N	paid	2026-01-02 00:00:00	\N	cash	119	2026-02-18 11:03:32.26	2026-02-18 11:04:11.895
2007	230450	\N	paid	2026-01-27 00:00:00	\N	cash	119	2026-02-18 11:03:32.26	2026-02-18 11:04:44.11
2037	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2039	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2040	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
1946	57963	57963	paid	2026-01-02 00:00:00	\N	cash	117	2026-02-18 10:55:19.966	2026-02-18 10:57:20.831
1948	156299	\N	paid	2026-02-16 00:00:00	\N	cash	117	2026-02-18 10:55:19.966	2026-02-18 10:57:46.345
1950	75553	\N	paid	2026-02-17 00:00:00	\N	cash	117	2026-02-18 10:55:19.966	2026-02-18 10:58:07.284
1977	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1979	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1980	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1981	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1982	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1983	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1984	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1985	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1986	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1987	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1988	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1989	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1990	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1991	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1992	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1993	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1994	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1995	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1996	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1997	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1998	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1999	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
2000	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
2001	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
2002	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
2003	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
2004	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
2005	\N	\N	due	\N	\N	online	118	2026-02-18 11:00:27.149	2026-02-18 11:00:27.149
1976	57963	\N	paid	2026-01-02 00:00:00	\N	cash	118	2026-02-18 11:00:27.149	2026-02-18 11:00:55.713
1978	231852	\N	paid	2026-01-02 00:00:00	\N	cash	118	2026-02-18 11:00:27.149	2026-02-18 11:01:16.696
2008	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2009	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2010	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2011	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2012	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2013	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2014	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2015	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2016	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2017	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2018	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2019	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2020	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2021	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2022	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2023	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2024	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2025	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2026	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2027	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2028	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2029	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2030	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2031	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2032	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2033	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2034	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2035	\N	\N	due	\N	\N	online	119	2026-02-18 11:03:32.26	2026-02-18 11:03:32.26
2041	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2042	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2043	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2044	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2045	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2046	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2047	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2048	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2049	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2050	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2051	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2052	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2053	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2054	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2055	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2056	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2038	230450	\N	paid	2026-01-19 00:00:00	\N	cash	120	2026-02-18 11:06:46.255	2026-02-18 11:08:13.059
2057	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2058	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2059	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2060	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2061	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2062	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2063	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2064	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2065	\N	\N	due	\N	\N	online	120	2026-02-18 11:06:46.255	2026-02-18 11:06:46.255
2036	\N	57605	paid	2026-01-02 00:00:00	\N	cash	120	2026-02-18 11:06:46.255	2026-02-18 11:07:45.92
207	198079	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 10:47:57.764	2025-11-06 10:55:39.874
211	99039	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 10:47:57.764	2026-03-12 11:20:51.049
209	99039	\N	paid	2023-12-31 00:00:00	\N	cheque	\N	2025-11-06 10:47:57.764	2025-11-06 10:58:44.673
210	99039	\N	paid	2024-01-24 00:00:00	\N	cheque	\N	2025-11-06 10:47:57.764	2025-11-06 11:11:13.876
212	99039	\N	paid	2025-10-23 00:00:00	\N	cheque	\N	2025-11-06 10:47:57.764	2026-03-12 11:22:29.585
213	99039	\N	paid	2025-11-06 00:00:00	\N	online	\N	2025-11-06 10:47:57.764	2026-03-12 11:22:57.139
214	21957	\N	due	2026-07-06 10:47:57.334	\N	online	\N	2025-11-06 10:47:57.764	2026-03-12 11:24:12.22
206	79231	\N	paid	2023-12-04 00:00:00	\N	cheque	\N	2025-11-06 10:47:57.764	2026-03-12 11:17:50.792
215	77082	\N	due	2026-08-06 10:47:57.334	\N	online	\N	2025-11-06 10:47:57.764	2026-03-12 11:23:36.76
216	1	\N	due	2026-09-06 10:47:57.334	\N	online	\N	2025-11-06 10:47:57.764	2026-03-12 11:24:25.736
2067	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2069	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2071	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2073	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2075	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2077	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2079	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2081	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2083	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2085	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2086	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2087	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2088	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2089	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2090	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2091	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2092	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2093	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2094	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2095	\N	\N	due	\N	\N	online	121	2026-03-12 11:48:41.883	2026-03-12 11:48:41.883
2070	99027	\N	paid	2026-03-12 15:50:40.64	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:00.104
2072	99027	\N	paid	2026-03-12 15:50:58.569	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:07.174
2080	99027	\N	paid	2026-03-12 15:52:31.264	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:35.577
2082	22917	\N	paid	2026-03-12 15:52:49.712	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:43.502
2084	76110	\N	paid	2026-03-12 15:53:07.775	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:50.075
2097	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2099	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2101	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2103	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2105	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2107	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2109	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2111	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2113	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2115	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2116	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2117	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2118	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2119	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2120	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2121	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2122	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2123	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2124	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2125	\N	\N	due	\N	\N	online	122	2026-03-12 11:59:27.95	2026-03-12 11:59:27.95
2100	198079	\N	paid	2026-03-12 16:00:31.626	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:20.55
2102	99039	\N	paid	2026-03-12 16:00:50.175	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:26.059
2110	99039	\N	paid	2026-03-12 16:01:54.024	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:50.274
2112	21957	\N	paid	2026-03-12 16:02:08.785	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:55.666
2114	77082	\N	paid	2026-03-12 16:02:22.418	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:56:16.23
2066	198054	\N	paid	2026-03-12 15:49:21.198	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:56:48.52
2068	198054	\N	paid	2026-03-12 15:50:16.088	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:56:54.333
2074	99027	\N	paid	2026-03-12 15:51:24.162	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:12.693
2076	79221	\N	paid	2026-03-12 15:51:46.3	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:20.86
2078	99027	\N	paid	2026-03-12 15:52:09.881	\N	cash	121	2026-03-12 11:48:41.883	2026-03-27 00:57:27.874
2129	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2131	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2133	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2135	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2137	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2134	95866	\N	paid	2026-03-12 16:17:26.712	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:14.22
2104	99039	\N	paid	2026-03-12 16:01:11.357	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:32.796
2126	76693	\N	paid	2026-03-12 16:16:24.171	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:53:49.122
2128	191733	\N	paid	2026-03-12 16:16:43.574	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:53:55.282
2130	191733	\N	paid	2026-03-12 16:16:56.32	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:01.084
2132	95866	\N	paid	2026-03-12 16:17:10.576	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:07.357
2136	95866	\N	paid	2026-03-12 16:17:54.399	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:20.581
2127	78042	\N	paid	2026-03-12 16:25:04.148	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:46.553
2096	79231	\N	paid	2026-03-12 15:59:55.669	\N	cash	122	2026-03-12 11:59:27.95	2026-03-27 00:55:09.23
2106	99039	\N	paid	2026-03-12 16:01:27.089	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:38.397
2108	99039	\N	paid	2026-03-12 16:01:40.992	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:44.597
2098	198079	\N	paid	2026-03-12 16:00:13.815	\N	online	122	2026-03-12 11:59:27.95	2026-03-27 00:55:15.089
2139	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2141	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2143	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2144	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2145	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2146	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2147	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2148	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2149	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2150	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2151	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2152	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2153	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2154	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2155	\N	\N	due	\N	\N	online	123	2026-03-12 12:09:11.843	2026-03-12 12:09:11.843
2170	182176	\N	paid	2026-03-12 16:36:27.167	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:53:07.348
2172	100000	\N	paid	2026-03-12 16:40:42.475	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:53:13.563
2174	82176	\N	paid	2026-03-12 16:40:58.073	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:53:19.986
2216	483410	\N	paid	2028-03-26 00:00:00	\N	cash	126	2026-03-27 01:01:50.17	2026-03-27 01:02:59.83
2247	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2157	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2159	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2161	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2163	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2165	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2167	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2169	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2171	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2173	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2175	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2176	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2177	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2178	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2179	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2180	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2181	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2182	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2183	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2184	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2185	\N	\N	due	\N	\N	online	124	2026-03-12 12:32:33.748	2026-03-12 12:32:33.748
2138	95866	\N	paid	2026-03-12 16:18:05.836	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:26.561
2140	95866	\N	paid	2026-03-12 16:20:25.44	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:32.897
2142	17823	\N	paid	2026-03-12 16:20:36.845	\N	online	123	2026-03-12 12:09:11.843	2026-03-27 00:54:39.604
2217	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2218	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2219	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2248	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2249	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2250	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2187	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2188	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2189	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2190	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2191	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2192	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2193	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2194	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2195	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2196	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2197	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2198	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2199	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2200	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2201	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2202	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2203	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2204	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2205	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2206	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2207	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2208	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2209	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2210	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2211	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2212	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2213	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2214	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2215	\N	\N	due	\N	\N	online	125	2026-03-27 00:49:37.82	2026-03-27 00:49:37.82
2220	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2186	483410	\N	paid	2028-03-26 00:00:00	\N	cash	125	2026-03-27 00:49:37.82	2026-03-27 00:51:51.096
2156	145741	\N	paid	2026-03-12 16:32:51.657	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:52:13.36
2158	364352	\N	paid	2026-03-12 16:33:39.001	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:52:20.508
2160	364352	\N	paid	2026-03-12 16:34:20.26	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:52:28.33
2162	182176	\N	paid	2026-03-12 16:34:58.312	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:52:37.764
2164	182176	\N	paid	2026-03-12 16:35:14.967	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:52:47.64
2166	182176	\N	paid	2026-03-12 16:35:46.525	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:52:54.076
2168	182176	\N	paid	2026-03-12 16:36:15.545	\N	online	124	2026-03-12 12:32:33.748	2026-03-27 00:53:00.513
2221	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2222	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2223	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2224	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2225	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2226	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2227	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2228	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2229	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2230	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2231	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2232	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2233	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2234	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2235	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2236	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2237	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2238	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2239	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2240	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2241	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2242	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2243	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2244	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2245	\N	\N	due	\N	\N	online	126	2026-03-27 01:01:50.17	2026-03-27 01:01:50.17
2251	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2252	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2253	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2254	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2255	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2256	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2257	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2258	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2259	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2260	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2261	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2262	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2263	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2264	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2265	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2266	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2267	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2268	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2269	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2270	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2271	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2272	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2273	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2274	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2275	\N	\N	due	\N	\N	online	127	2026-03-27 01:06:28.729	2026-03-27 01:06:28.729
2246	543786	\N	paid	2026-03-27 05:06:45.729	\N	cash	127	2026-03-27 01:06:28.729	2026-03-27 01:07:39.544
2277	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2278	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2279	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2280	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2281	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2282	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2283	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2284	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2285	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2286	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2287	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2288	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2289	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2290	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2291	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2292	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2293	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2294	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2295	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2296	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2297	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2298	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2299	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2300	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2301	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2302	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2303	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2304	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2305	\N	\N	due	\N	\N	online	128	2026-03-27 01:18:54.795	2026-03-27 01:18:54.795
2276	476506	\N	paid	2026-03-27 05:19:19.428	\N	cash	128	2026-03-27 01:18:54.795	2026-03-27 01:20:00.65
2307	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2308	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2309	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2310	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2311	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2312	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2313	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2314	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2315	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2316	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2317	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2318	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2319	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2320	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2321	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2322	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2323	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2324	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2325	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2326	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2327	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2328	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2329	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2330	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2331	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2332	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2333	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2334	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2335	\N	\N	due	\N	\N	online	129	2026-03-27 01:23:41.522	2026-03-27 01:23:41.522
2306	476506	\N	paid	2026-03-27 05:23:58.703	\N	cash	129	2026-03-27 01:23:41.522	2026-03-27 01:24:28.321
2337	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2338	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2339	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2340	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2341	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2342	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2343	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2344	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2345	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2346	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2347	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2348	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2349	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2350	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2351	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2352	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2353	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2354	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2355	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2356	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2357	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2358	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2359	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2360	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2361	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2362	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2363	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2364	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2365	\N	\N	due	\N	\N	online	130	2026-03-27 01:28:01.913	2026-03-27 01:28:01.913
2336	476506	\N	paid	2026-03-27 05:28:29.895	\N	cash	130	2026-03-27 01:28:01.913	2026-03-27 01:28:48.675
2367	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2368	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2369	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2370	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2371	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2372	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2373	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2374	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2375	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2376	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2377	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2378	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2379	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2380	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2381	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2382	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2383	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2384	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2385	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2386	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2387	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2388	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2389	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2390	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2391	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2392	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2393	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2394	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2395	\N	\N	due	\N	\N	online	131	2026-03-27 09:22:38.042	2026-03-27 09:22:38.042
2366	476506	\N	paid	2026-03-27 13:31:28.993	\N	cash	131	2026-03-27 09:22:38.042	2026-03-27 09:32:11.317
\.


--
-- TOC entry 3435 (class 0 OID 16658)
-- Dependencies: 219
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: db_continental_xowx_user
--

COPY public.users (id, email, name, password, role, "createdAt", "updatedAt", phone, "profileImage") FROM stdin;
2	sarah.manager@continental.com	Sarah Hassan	$2b$10$ljYLdM5Aq/NyPYJSdweXo.Om/iDkESAfEShwdJMgGKd0nWLsUbQsG	ADMIN	2025-10-29 23:26:59.813	2025-10-29 23:26:59.813	\N	\N
3	mohammed.ali@example.com	Mohammed Ali	$2b$10$vFYGnqsuNOACgYCj7ZsOtOir8A648PtPiaEp.vplgRTmVMSKunC02	USER	2025-10-29 23:27:01.448	2025-10-29 23:27:01.448	\N	\N
4	chinmay@example.com	John Doe	$2b$10$ZkYGOFBfIhevN9RGCWL.GO0h9q.lgDGG3/VvcJp1eBaL5Djsq5ZpO	USER	2025-10-30 10:16:02.41	2025-10-30 10:16:02.41	\N	\N
6	abdalla@continental.com	Admin User	$2b$10$Fy8ZCenMeeS3Z9x1aWUga.1Yb2XR2FY0Evf3w8zCnYm0DaWifj2IG	ADMIN	2025-10-31 13:49:31.554	2025-10-31 13:49:31.554	\N	\N
7	abdalla@continental.ae	Amadou	$2b$10$TzL50uFLPNfgGKcw/v2up.EqmtPm59b3hssMjd5PD7bRm4DTwvaDm	ADMIN	2025-10-31 13:49:38.869	2025-11-03 17:05:05.738	553776910	https://continentalimages.s3.ap-south-1.amazonaws.com/user-profiles/1762189466857-7087fb0e430cf70d57bd7d7f0a6eb36b.jpg
5	admin@gmail.com	Continental Admin 	$2b$10$bgxvU1Iy11BSCLSoI2BX5OmmhXarro/mRACf4W5MVf.xjAnHuRoqa	USER	2025-10-30 10:17:51.512	2025-11-05 17:19:00.889		https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80
1	admin@continental.com	testing	$2b$10$Ai9rmv2m23u2LsacaGr1je5f4K5YzMYyQzSBhS0PQNQ8mPlZnrZx6	ADMIN	2025-10-29 23:26:57.244	2025-12-29 13:13:21.065	14324321324	https://continentalimages.s3.ap-south-1.amazonaws.com/user-profiles/1762423535853-c2c32d05e69235a3ef541c7c5a9635a3.jpg
\.


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 220
-- Name: leads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: db_continental_xowx_user
--

SELECT pg_catalog.setval('public.leads_id_seq', 4, true);


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 222
-- Name: occupant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: db_continental_xowx_user
--

SELECT pg_catalog.setval('public.occupant_records_id_seq', 131, true);


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 224
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: db_continental_xowx_user
--

SELECT pg_catalog.setval('public.payments_id_seq', 2395, true);


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 218
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: db_continental_xowx_user
--

SELECT pg_catalog.setval('public.users_id_seq', 7, true);


--
-- TOC entry 3277 (class 2606 OID 16642)
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 3282 (class 2606 OID 16678)
-- Name: leads leads_pkey; Type: CONSTRAINT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_pkey PRIMARY KEY (id);


--
-- TOC entry 3284 (class 2606 OID 16689)
-- Name: occupant_records occupant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.occupant_records
    ADD CONSTRAINT occupant_records_pkey PRIMARY KEY (id);


--
-- TOC entry 3286 (class 2606 OID 16752)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 3280 (class 2606 OID 16667)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3278 (class 1259 OID 16679)
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: db_continental_xowx_user
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- TOC entry 3287 (class 2606 OID 16753)
-- Name: payments payments_occupantRecordId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db_continental_xowx_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "payments_occupantRecordId_fkey" FOREIGN KEY ("occupantRecordId") REFERENCES public.occupant_records(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: db_continental_xowx_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- TOC entry 2091 (class 826 OID 16391)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON SEQUENCES TO db_continental_xowx_user;


--
-- TOC entry 2093 (class 826 OID 16393)
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES TO db_continental_xowx_user;


--
-- TOC entry 2092 (class 826 OID 16392)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON FUNCTIONS TO db_continental_xowx_user;


--
-- TOC entry 2090 (class 826 OID 16390)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES TO db_continental_xowx_user;


-- Completed on 2026-04-02 01:21:44

--
-- PostgreSQL database dump complete
--

