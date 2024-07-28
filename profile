wget https://github.com/zubkov-andrei/pg_profile/releases/download/4.6/pg_profile--4.6.tar.gz

tar xzf pg_profile--4.6.tar.gz --directory /usr/pgsql-16/share/extension/

CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION dblink;
CREATE SCHEMA profile;
CREATE EXTENSION pg_profile SCHEMA profile;

#### Consider setting following Statistics Collector parameters:

```
track_activities = on
track_counts = on
track_io_timing = on
track_wal_io_timing = on      # Since Postgres 14
track_functions = all/pl
```

select * from profile.show_servers();
