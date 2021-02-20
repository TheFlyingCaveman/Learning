--liquibase formatted sql
--changeset id:1324 author:JoshuaMiller
--comment: Departments encapsulates BigCorp departments
ALTER TABLE BigCorp.Departments
ADD 
    description text;
--rollback ALTER TABLE BigCorp.Departments DROP description;