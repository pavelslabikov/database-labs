-- ����� ��� ���������
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA66', 6); 
-- �������������� ������
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A134RA766', 6); 
-- ������������ ������ ������
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), '11111166', 6); 
-- ��� ���� ������ ������� � ���� ����� � ������� 4
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A123BC74', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, getdate(), 'A123BC74', 4);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry
-- ��� ���� ������ ������� �� �������������  ����� ������ �����
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC66', 1);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC74', 3);
DELETE FROM KB301_Slabikov_Lab3.dbo.registry


DELETE FROM KB301_Slabikov_Lab3.dbo.recordings
/* ������ O777AO174 �� ����� ���:
1. ����� �� ����� ����� 4 ����
2. ����� � ����� ����� 6 ����
���������: ������ �������
*/
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'O777AO174', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'O777AO174', 6);

/* ������ A123BC66 �� ������������ ���:
1. ����� �� ��� ����� 0 ����
2. ����� � ����� ����� 4 ����
3. ����� �� ����� ����� 7 ����
4. ����� � ��� ����� 1 ����
���������: ������ ���������� � �����
*/
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, getdate(), 'A123BC66', 0);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 1, getdate()), 'A123BC66', 4);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 0, DATEADD(hour, 2, getdate()), 'A123BC66', 7);
INSERT INTO KB301_Slabikov_Lab3.dbo.registry
VALUES
(default, 1, DATEADD(hour, 3, getdate()), 'A123BC66', 1);









