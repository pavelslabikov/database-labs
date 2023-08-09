USE kb301_slabikov_lab1;

/*
 * 0 - ���� ����������� ������
 * 1 - ���� ������� ������
*/

/* ���������� ������������� ������ �� ���� ��������� */
SELECT tip.t_name         AS ��������_������,
       Sum(tovari.amount) AS ����������,
       izmer.m_name       AS �������_���������
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
GROUP  BY tip.t_name,
          izmer.m_name


/* ����������� ������� ���� ������� ����� ���� ��������� */
SELECT tip.t_name        AS �����,
       Avg(tovari.price) AS ����_����
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
GROUP  BY tip.t_name


/* ���������� ��������� �������� (� 2021-10-06 �� ������� ����) �� ������� �������� (� ��. ���������)*/
SELECT markets.NAME       AS �������,
       Sum(tovari.amount) AS ����������,
       izmer.m_name       AS �������_���������
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
WHERE  tovari.priznak = 1
       AND '2021-10-06' <= tovari.post_prod
       AND tovari.post_prod <= Getdate()
       AND tip.t_name = '�������'
GROUP  BY markets.NAME,
          izmer.m_name


/* ����������� ���������� ������� �� ������� � ������ �������� */
SELECT markets.NAME       AS �������,
       t_group.g_name     AS ������_�������,
       Sum(tovari.amount) AS ����������
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.t_group AS t_group
               ON t_group.id_g = tip.id_g
GROUP  BY markets.NAME,
          t_group.g_name


/* ����� ����� �����, ���������� �� ������� ������� (�� 2021-10-10) �� ������� ����*/
SELECT tip.t_name        AS ���_������,
       Sum(tovari.price) AS �������
FROM   slabikov.tip_tovara AS tip
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_t = tip.id_t
WHERE  tovari.priznak = 1
       AND tovari.post_prod <= '2021-10-10'
GROUP  BY tip.t_name;


/* ����������� ���. ���� ������� ����� ���� ��������� */
SELECT tip.t_name        AS �����,
       Min(tovari.price) AS ���_����
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
GROUP  BY tip.t_name


/* ���-�� �������, ������� �������� � ������� � 2021-10-9 �� ������� ���� */
SELECT tip.t_name         AS ���_������,
       Sum(tovari.amount) AS ����������_������,
       izmer.m_name       AS �������_���������
FROM   slabikov.tip_tovara AS tip
       INNER JOIN slabikov.tovar AS tovari
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
WHERE  tovari.priznak = 0
       AND tovari.post_prod = '2021-10-9'
GROUP  BY tip.t_name,
          izmer.m_name


/* ����������� ����. ���� ������� ����� ���� ��������� */
SELECT tip.t_name        AS �����,
       Max(tovari.price) AS ����_����
FROM   slabikov.tovar AS tovari
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
GROUP  BY tip.t_name


/* ���������� ������ � ������� (�� 2021-10-09) �� ������� �������� (� ��. ���������)*/
SELECT markets.NAME       AS �������,
       Sum(tovari.amount) AS ����������,
       izmer.m_name       AS �������_���������
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
       INNER JOIN slabikov.izmer AS izmer
               ON tip.id_i = izmer.id_i
WHERE  tovari.priznak = 0
       AND tovari.post_prod <= '2021-10-09'
       AND tip.t_name = '�����'
GROUP  BY markets.NAME,
          izmer.m_name


/* ����������� ���. ���� � �������� �� ������� �������� */
SELECT markets.NAME      AS �������,
       Min(tovari.price) AS ����
FROM   slabikov.market AS markets
       INNER JOIN slabikov.tovar AS tovari
               ON tovari.id_m = markets.id_m
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_t = tovari.id_t
WHERE  tip.t_name = '�������'
GROUP  BY markets.NAME;


/* ������� ���� ��������� ����� ������� �� ���� ��������� */
SELECT t_group.g_name    AS ������_������,
       Avg(tovari.price) AS �������_����_�������
FROM   slabikov.t_group AS t_group
       INNER JOIN slabikov.tip_tovara AS tip
               ON tip.id_g = t_group.id_g
       INNER JOIN slabikov.tovar AS tovari
               ON tip.id_t = tovari.id_t
WHERE  tovari.priznak = 1
GROUP  BY t_group.g_name 