--liquibase formatted sql
--changeset id:123 author:JoshuaMiller
--comment: BigCorp encapsulates important BigCorp concepts
CREATE SCHEMA BigCorp
--rollback DROP SCHEMA BigCorp;