INSERT INTO TasksTable VALUES (Task_type(1, 'Oil Change', 150.0, 1.5));
INSERT INTO TasksTable VALUES (Task_type(2, 'Engine Repair', 1200.0, 10.5));
INSERT INTO TasksTable VALUES (Task_type(3, 'Tire Replacement', 200.0, 2.5));
INSERT INTO TasksTable VALUES (Task_type(4, 'Brake Inspection', 100.0, 0.5));
INSERT INTO TasksTable VALUES (Task_type(5, 'Battery Replacement', 180.0, 1.0));
INSERT INTO TasksTable VALUES (Task_type(6, 'Air Filter Change', 80.0, 0.5));
INSERT INTO TasksTable VALUES (Task_type(7, 'Coolant Flush', 120.0, 1.5));
INSERT INTO TasksTable VALUES (Task_type(8, 'Transmission Flush', 300.0, 3.5));
COMMIT;

select * from TasksTable