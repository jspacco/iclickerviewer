SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'iclickerviewer_full' AND pid <> pg_backend_pid();

CREATE DATABASE iclickerviewer WITH TEMPLATE iclickerviewer_full OWNER iclickerviewer;

\c iclickerviewer;

delete from votes;
