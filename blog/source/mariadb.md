---
title: mariadb | shira.at
toc: true
header-includes:
    <link rel="stylesheet" href="/style.css">
---


## About

This page is a summary of my learnings with mariadb.

It is not supposed to be a complete overview or a detailed guide on how to use it, but instead just a collection of experiences and accidental benchmarks.


## Installing and Configuration

To install mariadb simply use the default command:

    sudo apt-get install mariadb-server

The only config you may have to change is the listening IP.  
By default the mariadb server only listens on localhost port 3306, which means no one can connect from the outside.  
To enable this you have to edit this in the config that is located in Debian 11 at:

    /etc/mysql/mariadb.conf.d/50-server.cnf

There around line 30 you can change the bind-address to 0.0.0.0 to allow external access.


## Storage

I have over 50.000.000 (50million) chat messages saved in one table and around 10.000.000 log lines in another table.  
If i export both with mariadb-dump I get around 6GB of .sql text files.  
The lib folder which contains the database files directly are 7GB in size.


## Backups

Taken from my mariadb-vs-postgres blog:  
Backing up 45.000.000 chat messages with mariadb-dump (or the old mysqldump command) takes around 1.5minutes.

Important: During a backup of a MariaDB InnoDB Database the tables and data are NOT blocked!  
If you create a backup with the following command:

    mariadb-dump --single-transaction --databases mydatabase > backup.sql

Then any other connection can still INSERT or SELECT data from the tables of this database.  
This is because of the `--single-transaction` flag, which requires the storage engine InnoDB and allows you to do non-blocking backups.  

*Warning: If you insert data during a backup it will not be included in it!*

If you do not use this flag then a backup blocks INSERT statements but you can still use SELECT during it.

Source:

 - Tested myself
 - [https://mariadb.com/docs/server/ref/mdb/cli/mariadb-dump/single-transaction/](https://mariadb.com/docs/server/ref/mdb/cli/mariadb-dump/single-transaction/)
 - [https://mariadb.com/kb/en/mariadb-dump/#examples](https://mariadb.com/kb/en/mariadb-dump/#examples)


## Performance

My installation of mariadb was never "tuned for performance".  

An example of how to raise performance: Set the InnoDB buffer to ~80% of your available RAM.

I have done nothing the like (buffer is at 128MB) and I still get an immense performance out of it.

**A short story about an accidental database benchmark:**

I am currently storing logs for gameservers.  
The server for storing this has 4 CPU cores and 8GB of RAM with 128MB of that being InnoDB buffer.  
They send me logs in 100 lines per request.  
The request flow is: gameserver -> nginx -> golang-webserver -> mariadb  
I save all those 100 lines in a single transaction via my golang webserver (which uses gin and sqlx)

One time someone found out how to create an exponential damage-creator on a gameserver.  
This created 330.000 log lines in ~15 seconds.  
These were sent via 3.300 requests to me and were successfully saved.

Grafana showed me in a single 15s scrape-tick:

 - CPU usage of ~54%
 - 3300 requests to my golang webserver
 - 3260 of these requests were done within 10ms
 - 24Mb/s network traffic
 - 330.000 new log lines in mariadb
 - 7.720 QPS (queries per second) on the mariadb
 - 10MB/s disk R/W
 - 254 io/s IOps on the disk
 - only 2 database connections open from my go webserver
 - no crashes, lags or other

According to the timestamps with which the log lines have been inserted into the mariadb it was around 20.000 log lines per second for around 15 seconds.  
The SQL used to see this is:

    SELECT COUNT(datetime),datetime FROM logs WHERE datetime BETWEEN '1970-01-02 13:01:00' AND '1970-01-02 13:02:15' GROUP BY datetime;

Also, the above SQL statement took, in a table with 5 million loglines, only 3.8s to complete.

To summarize this, you do not need to tune for performance as long as you do not have more than ~30.000 queries/second consistently.


## Performance by using index

Using an index for an often queried column can help your performance a lot.

An example:
Using the same server as above (4core 8GB debian12 server) there is another application. It has 1.000.000 rows and has the column `serverid` which consists of around ~30 different IDs. If someone uses the application it executes 5 different queries which use the `serverid` column in a WHERE clause.

By default (without an index) it takes 0.25s (250ms) to execute one of those queries. The browser shows a time of ~600ms for this request and also the turtle icon because the request was slow.

After creating an index on this column (with `CREATE INDEX serverid ON server(serverid)`) it takes 0.01s (1ms) to execute the same query as above. The browser shows only 50ms of time taken for the whole request.

Creating this index took only ~3seconds on a table with 1 million entries. Dropping it with `DROP INDEX serverid ON server` only takes around 3 seconds too.


