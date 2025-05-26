CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
ALTER TABLE donnees.flore
ADD COLUMN id UUID DEFAULT uuid_generate_v4();


ALTER TABLE donnees.flore
DROP CONSTRAINT flore_pkey; 


ALTER TABLE donnees.flore
ADD COLUMN id bigint GENERATED ALWAYS AS IDENTITY;

ALTER TABLE donnees.flore
ADD PRIMARY KEY (id);


ALTER TABLE donnees.flore DROP CONSTRAINT IF EXISTS flore_pkey;

ALTER TABLE donnees.flore ADD PRIMARY KEY (uuid);


ALTER TABLE donnees.flore 
ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();

CREATE UNIQUE INDEX uniq_flore_uuid ON donnees.flore(uuid);

ALTER TABLE donnees.flore
ADD CONSTRAINT flore_uuid_unique UNIQUE (uuid);
