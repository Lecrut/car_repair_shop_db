CREATE TABLE WorkshopTable OF Workshop;

CREATE TABLE TasksTable OF Task_type (PRIMARY KEY (TaskID));

CREATE TABLE EmployeesTable  OF Employee_type (PRIMARY KEY (EmployeeID));

CREATE TABLE ClientTable OF Owner_type (PRIMARY KEY (OwnerID));

CREATE TABLE CarTable OF Car_type (PRIMARY KEY (CarID));

CREATE TABLE ServiceTable OF Service_type (PRIMARY KEY (ServiceID));
