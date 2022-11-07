create table if not exists eml_verification (
	id uuid not null primary key,
	create_time timestamp not null,
	request_ip varchar(500) not null,
	id_user uuid null references "user"(id),
	email varchar(500) not null,
	verify_success boolean not null,
	verify_error_description text null
);
