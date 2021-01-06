--liquibase formatted sql
--changeset id:1324 author:JoshuaMiller
--comment: Departments encapsulates BigCorp departments
ALTER TABLE BigCorp.Departments
ADD 
    id int;
--rollback ALTER TABLE BigCorp.Departments DROP id;