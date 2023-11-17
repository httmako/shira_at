---
title: mariadb/postgres | shira.at
toc: true
header-includes:
    <link rel="stylesheet" href="https://shira.at/style.css">
---


A comparison of mariadb and postgresql based on a real life example.

## Introduction

I wrote a twitch chat logger a long time ago with the sole goal to help a streamer with their chat moderation.  
After a while I added even more streamers and rewrote it from a file-based NodeJS application to a database Golang application.

At the time of testing it had a bit over 45.000.000 chat messages logged in the database. With this amount of data I was able to test the performance of both databases.

The table looks as follows:

```sql
CREATE TABLE IF NOT EXISTS messages(
    id SERIAL,
    streamer VARCHAR(255),
    user VARCHAR(255),
    message LONGTEXT,
    intime DATETIME NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB
```

The mariadb SERIAL type is an id with auto increment and index.

The hardware used: 8GB RAM, 4-core AMD EPYC 7702P CPU, 2.5inch SSD.

The data was transfered from mariadb to postgres with pgloader.


## Comparison

### GROUP BY

Usecase: I want to know how many messages were received per day.  
This is best solved within the database via a query.

```sql
SELECT COUNT(*), DATE(intime) FROM messages GROUP BY DATE(intime);
```


    | mariadb | postgresql |
    |---------|------------|
    | 24s     | 4s         |

This benchmark showed mariadb only using one core at once with 100% usage. Postgres used 3 cores at once with 60-100% usage with each core.

---

### DATE Interval

Usecase: I want to get the amount of messages that were saved in the last 24hours.

```sql
//mariadb:
SELECT COUNT(*) FROM messages WHERE intime >= DATE_SUB(NOW(), INTERVAL 1 DAY);
//postgres:
SELECT COUNT(*) FROM messages WHERE intime >= NOW() - INTERVAL '1 DAY';
```

    | mariadb | postgresql |
    |---------|------------|
    | 12s     | 12s        |

Here only one core was used by both postgres and mariadb.

---

### Backup & Restore

Usecase: I want to backup (and in the case of an emergency restore) the database without much downtime.

I tested both database systems with their respective backup commands.

    | type    | mariadb   | postgres |
    |---------|-----------|----------|
    | backup  | mysqldump | pg_dump  |
    | restore | mysql     | psql     |

Both database systems support the use of non-blocking backups. This means that you can create a complete and consistent snapshot of your database during ongoing operation without any downtime or waiting inserts.

Source: 
 - [https://www.postgresql.org/docs/current/backup-dump.html](https://www.postgresql.org/docs/current/backup-dump.html) - last paragraph before 26.1.1
 - [https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html#option_mysqldump_single-transaction](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html#option_mysqldump_single-transaction)

The times taken:

    | type    | mariadb   | postgres |
    |---------|-----------|----------|
    | backup  | 1:11min   | 1:04min  |
    | restore | 10:02min  | 2:10min  |


The mariadb backup .sql file was 3.6GB in size.  
After using gzip to compress it the size went down to 772MB.  
Just for clarification: Those are 45 million database rows in those backups.


## Objective conclusion

Postgres is faster with GROUP BY statements but not faster with DATE() calculation of column values.  
The backup process with mariadb is more clean (because it creates only one .sql file) but not faster than postgres.  
The restore of backups with postgres is way faster than with mariadb.


## Subjective conclusion

Postgres is faster than mariadb but also a bit more complex.

All the basic mysql logic you learned back in school doesn't apply to postgres. For example: You have to use \l to list databases.
My colleagues always say "postgres is the free oracle", and I think they are right. MariaDB should be used for smaller projects but if it gets big and complex then PostgreSQL is my go-to pick.


## Experience fter 1 year of using MariaDB server

I have been using a MariaDB server for storing any and all data of my now 5 self hosted applications.

According to grafana I have 3qps/night and 7qps/day on average and I peak with up to 13 queries per second, saving up to 50.000 chat messages and a few thousand log/statistic lines per day.

There has never been any performance or delay problem with mariadb.

Even calculating the sum and count of a 500.000 row table with 2 WHERE's (and a few other queries added) does not take more than 400ms on average to return all the data.

The fact that mariadb holds up with these loads made me not switch to postgres yet as it would take time to migrate all applications even though they all work flawlessly right now.
