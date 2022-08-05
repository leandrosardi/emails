create table IF NOT EXISTS eml_gmail (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this account
    create_time timestamp not null, -- where registered this account
    "address" varchar(255) not null, -- example: ceo123@gmail.com
    share boolean not null, -- true if I am willing to rent this account to other users of the platform
    shared_id_account uuid null references account(id), -- if share is true, this is the id of the account is renting it
    max_emails_per_hour int not null, -- how many emails per hour can deliver
    max_emails_per_day int not null -- how many emails per day can deliver
);
