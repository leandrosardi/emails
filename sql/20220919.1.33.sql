alter table eml_mta add column if not exists inbox_label varchar(500) not null default 'Inbox';

alter table eml_mta add column if not exists spam_label varchar(500) not null default 'Spam';

alter table eml_mta add column if not exists search_all_wildcard varchar(500) not null default '';


update eml_mta set 
inbox_label='Inbox', spam_label='[Gmail]/Spam', search_all_wildcard='*' where 
imap_address='imap.googlemail.com';

update eml_mta set 
inbox_label='Inbox', spam_label='Junk', search_all_wildcard='' where 
imap_address='outlook.office365.com';
