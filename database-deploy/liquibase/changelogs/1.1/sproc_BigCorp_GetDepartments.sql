--liquibase formatted sql

--changeset JoshuaMiller:2 endDelimiter:|
--comment: GetAllDepartments returns all BigCorp departments
CREATE PROCEDURE BigCorp.GetAllDepartments()
BEGIN
	SELECT id, name, description  FROM BigCorp.Departments;
END
|
--rollback DROP PROCEDURE BigCorp.GetAllDepartments;