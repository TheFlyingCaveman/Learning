--liquibase formatted sql
--changeset author:JoshuaMiller
--comment: some comment that may turn into database comments later
CREATE SCHEMA schema2
--rollback DROP SCHEMA schema2