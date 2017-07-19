SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'iclickerviewer' AND pid <> pg_backend_pid();

CREATE DATABASE iclickerviewer_forupload WITH TEMPLATE iclickerviewer OWNER iclickerviewer;

\c iclickerviewer_forupload;

delete from votes;
