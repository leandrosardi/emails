create table IF NOT EXISTS eml_address (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this account
    create_time timestamp not null, -- when registered this account
    "type" int not null, -- 0 - gmail, 1 - yahoo, 2 - hotmail
    "address" varchar(255) not null, -- example: ceo123@gmail.com
    shared boolean not null, -- true if I am willing to rent this account to other users of the platform
    shared_id_account uuid null references account(id), -- if shared is true, this is the id of the account is renting it
    max_deliveries_per_day int not null -- how many emails per day can deliver
);

create table IF NOT EXISTS eml_campaign (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this
    create_time timestamp not null, -- when registered this
    -- header settings
    "name" varchar(255) not null, -- name of the campaign
    id_export uuid not null references fl_export(id), -- id of the export that will be used to send the emails
    -- content of the campaign  
    "subject" varchar(255) not null, -- subject of the campaign
    body text not null, -- body of the campaign
    from_name varchar(255) not null, -- from of the campaign
    from_email varchar(255) not null, -- from of the campaign
    reply_to varchar(255) not null, -- reply to of the campaign
    "type" int not null, -- 0 - plain text, 1 - html
    "status" int not null, -- 0 - draft, 1 - sent, 2 - error
    -- statistics of the campaign
    stat_sent bigint not null, -- how many emails were sent
    stat_opens bigint not null, -- how many emails were opened
    stat_clicks bigint not null, -- how many emails were clicked
    stat_bounces bigint not null, -- how many emails were bounced
    stat_unsubscribes bigint not null, -- how many emails were unsubscribed
    stat_camplaints bigint not null, -- how many emails were complained
    -- schedule of the campaign
    schedule_start_time timestamp not null, -- when the campaign will be sent
    schedule_hour_0 boolean not null, -- true if the campaign is scheduled at 0 hour
    schedule_hour_1 boolean not null, -- true if the campaign is scheduled at 1 hour
    schedule_hour_2 boolean not null, -- true if the campaign is scheduled at 2 hour
    schedule_hour_3 boolean not null, -- true if the campaign is scheduled at 3 hour
    schedule_hour_4 boolean not null, -- true if the campaign is scheduled at 4 hour
    schedule_hour_5 boolean not null, -- true if the campaign is scheduled at 5 hour
    schedule_hour_6 boolean not null, -- true if the campaign is scheduled at 6 hour
    schedule_hour_7 boolean not null, -- true if the campaign is scheduled at 7 hour
    schedule_hour_8 boolean not null, -- true if the campaign is scheduled at 8 hour
    schedule_hour_9 boolean not null, -- true if the campaign is scheduled at 9 hour
    schedule_hour_10 boolean not null, -- true if the campaign is scheduled at 10 hour
    schedule_hour_11 boolean not null, -- true if the campaign is scheduled at 11 hour
    schedule_hour_12 boolean not null, -- true if the campaign is scheduled at 12 hour
    schedule_hour_13 boolean not null, -- true if the campaign is scheduled at 13 hour
    schedule_hour_14 boolean not null, -- true if the campaign is scheduled at 14 hour
    schedule_hour_15 boolean not null, -- true if the campaign is scheduled at 15 hour
    schedule_hour_16 boolean not null, -- true if the campaign is scheduled at 16 hour
    schedule_hour_17 boolean not null, -- true if the campaign is scheduled at 17 hour
    schedule_hour_18 boolean not null, -- true if the campaign is scheduled at 18 hour
    schedule_hour_19 boolean not null, -- true if the campaign is scheduled at 19 hour
    schedule_hour_20 boolean not null, -- true if the campaign is scheduled at 20 hour
    schedule_hour_21 boolean not null, -- true if the campaign is scheduled at 21 hour
    schedule_hour_22 boolean not null, -- true if the campaign is scheduled at 22 hour
    schedule_hour_23 boolean not null, -- true if the campaign is scheduled at 23 hour
    schedule_day_0 boolean not null, -- true if the campaign is scheduled at 0 day
    schedule_day_1 boolean not null, -- true if the campaign is scheduled at 1 day
    schedule_day_2 boolean not null, -- true if the campaign is scheduled at 2 day
    schedule_day_3 boolean not null, -- true if the campaign is scheduled at 3 day
    schedule_day_4 boolean not null, -- true if the campaign is scheduled at 4 day
    schedule_day_5 boolean not null, -- true if the campaign is scheduled at 5 day
    schedule_day_6 boolean not null, -- true if the campaign is scheduled at 6 day
    schedule_day_7 boolean not null -- true if the campaign is scheduled at 7 day
);

-- each URL in the body is replaced by this link
-- filter for tracking clicks receive 2 parameters: id of the link and id of the lead.
create table IF NOT EXISTS eml_link (
    id uuid not null primary key,
    id_campaign uuid not null references eml_campaign(id), 
    create_time TIMESTAMP NOT NULL,
    link_number int NOT NULL, -- the number of the link in the body
    "url" VARCHAR(8000) NOT NULL, -- the url to redirect.
    CONSTRAINT uk_link UNIQUE (id_campaign, "link_number")
);

create table IF NOT EXISTS eml_job (
    id uuid not null primary key,
    id_campaign uuid not null references eml_campaign(id), 
    create_time TIMESTAMP NOT NULL,
    delivery_start_time TIMESTAMP NULL,
    delivery_end_time TIMESTAMP NULL,
    delivery_success boolean null,
    delivery_error_description varchar(8000) null
);

alter table eml_job add column IF NOT EXISTS planning_id_address uuid not null references eml_address(id);
alter table eml_job add column IF NOT EXISTS planning_time timestamp not null; 

create table IF NOT EXISTS eml_delivery (
    id uuid not null primary key,
    id_job uuid not null references eml_job(id), 
    id_lead uuid not null references fl_lead(id),
    create_time TIMESTAMP NOT NULL,
    delivery_start_time TIMESTAMP NULL,
    delivery_end_time TIMESTAMP NULL,
    delivery_success boolean null,
    delivery_error_description varchar(8000) null
);

-- one lead may have more than 1 email address, so I have to specify the email address to deliver the email to
alter table eml_delivery add column if not exists email varchar(500) not null;
alter table eml_delivery add column if not exists subject varchar(8000) not null;
alter table eml_delivery add column if not exists body text not null;

create table IF NOT EXISTS eml_open (
    id uuid not null primary key,
    id_delivery uuid not null references eml_delivery(id), 
    create_time TIMESTAMP NOT NULL
);

create table IF NOT EXISTS eml_click (
    id uuid not null primary key,
    id_delivery uuid not null references eml_delivery(id), 
    id_link uuid not null references eml_link(id),
    create_time TIMESTAMP NOT NULL
);

create table IF NOT EXISTS eml_unsubscribe (
    id uuid not null primary key,
    id_delivery uuid not null references eml_delivery(id), 
    create_time TIMESTAMP NOT NULL
);

-- add planning fields to the campaign
alter table eml_campaign add column if not exists planning_start_time timestamp null;
alter table eml_campaign add column if not exists planning_end_time timestamp null;
alter table eml_campaign add column if not exists planning_success boolean null;
alter table eml_campaign add column if not exists planning_error_description varchar(8000) null;

-- remove this feature of allocating gmail addresses to other users.
alter table eml_address drop column if exists shared_id_account;

-- timeline snapshot of deliveries
create table IF NOT EXISTS eml_timeline (
    id uuid not null primary key,
    id_campaign uuid not null references eml_campaign(id), 
    create_time TIMESTAMP NOT NULL,
    year int not null,
    month int not null,
    day int not null,
    hour int not null,
    minute int not null,
    stat_sent bigint not null,
    stat_opens bigint not null,
    stat_clicks bigint not null,
    stat_bounces bigint not null,
    stat_unsubscribes bigint not null,
    stat_camplaints bigint not null,
    CONSTRAINT uk_timeline UNIQUE (id_campaign, year, month, day, hour, minute)
);

-- add support to delete objects
alter table eml_address add column if not exists delete_time timestamp null;
alter table eml_campaign add column if not exists delete_time timestamp null;

-- hourly limit for emails delivery has been deprecated.
alter table eml_address drop column if exists max_emails_per_hour;


-- TODO: create trigger: when sent an email, increase the stat_sent field of the campaign, blocking concurrent access

-- TODO: create trigger: when track open, increase the stat_opens field of the campaign

-- TODO: create trigger: when track click, increase the stat_clicks field of the campaign

-- TODO: create trigger: when track bounce, increase the stat_bounces field of the campaign

-- TODO: create trigger: when track unsubscribe, increase the stat_unsubscribes field of the campaign

-- TODO: create trigger: when track complaint, increase the stat_camplaints field of the campaign