--liquibase formatted sql
--changeset id:1324 author:JoshuaMiller
--comment: Departments encapsulates BigCorp departments
CREATE TABLE BigCorp.Departments (
    name VARCHAR(50)
)
--rollback DROP TABLE BigCorp.Departments;