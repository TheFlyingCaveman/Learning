--liquibase formatted sql
--changeset author:JoshuaMiller
--comment: some comment that may turn into database comments later
CREATE SCHEMA schema1
--rollback DROP SCHEMA schema1