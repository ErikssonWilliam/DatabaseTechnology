/*Assignment 2, Martin Hallbäck(marha614) and William Eriksson (wiler441)*/
SOURCE company_schema.sql;
SOURCE company_data.sql;

/* Question 1*/
SELECT * FROM jbemployee;
/*+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0,00 sec)*/


/* Question 2*/
SELECT DISTINCT name FROM jbdept ORDER BY name;
/*+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
+------------------+
16 rows in set (0,00 sec)
*/

/* Question 3*/
SELECT name FROM jbparts WHERE qoh = '0';
/*+-------------------+
| name              |
+-------------------+
| card reader       |
| card punch        |
| paper tape reader |
| paper tape punch  |
+-------------------+
4 rows in set (0,01 sec)*/

/* Question 4*/
SELECT name FROM jbemployee WHERE salary >= '9000' and salary <= '10000';
/*+----------------+
| name           |
+----------------+
| Edwards, Peter |
| Smythe, Carol  |
| Williams, Judy |
| Thomas, Tom    |
+----------------+
4 rows in set (0,00 sec)*/


/* Question 5*/
SELECT name, startyear-birthyear FROM jbemployee;
/*+--------------------+---------------------+
| name               | startyear-birthyear |
+--------------------+---------------------+
| Ross, Stanley      |                  18 |
| Ross, Stuart       |                   1 |
| Edwards, Peter     |                  30 |
| Thompson, Bob      |                  40 |
| Smythe, Carol      |                  38 |
| Hayes, Evelyn      |                  32 |
| Evans, Michael     |                  22 |
| Raveen, Lemont     |                  24 |
| James, Mary        |                  49 |
| Williams, Judy     |                  34 |
| Thomas, Tom        |                  21 |
| Jones, Tim         |                  20 |
| Bullock, J.D.      |                   0 |
| Collins, Joanne    |                  21 |
| Brunet, Paul C.    |                  21 |
| Schmidt, Herman    |                  20 |
| Iwano, Masahiro    |                  26 |
| Smith, Paul        |                  21 |
| Onstad, Richard    |                  19 |
| Zugnoni, Arthur A. |                  21 |
| Choy, Wanda        |                  23 |
| Wallace, Maggie J. |                  19 |
| Bailey, Chas M.    |                  19 |
| Bono, Sonny        |                  24 |
| Schwarz, Jason B.  |                  15 |
+--------------------+---------------------+
25 rows in set (0,00 sec)*/


/* Question 6*/
SELECT name FROM jbemployee WHERE name LIKE '%son, %';
/*+---------------+
| name          |
+---------------+
| Thompson, Bob |
+---------------+
1 row in set (0,01 sec)*/

/* Question 7*/
SELECT name FROM jbitem WHERE supplier IN(SELECT id FROM jbsupplier WHERE name = 'Fisher-Price');
/*+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
3 rows in set (0,00 sec)*/

/* Question 8*/
SELECT jbitem.name FROM jbitem JOIN jbsupplier ON jbitem.supplier = jbsupplier.id
WHERE jbsupplier.name = 'Fisher-Price';
/*+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
3 rows in set (0,00 sec)*/

/* Question 9*/
SELECT name FROM jbcity WHERE id IN(SELECT city FROM jbsupplier);
/*+----------------+
| name           |
+----------------+
| Amherst        |
| Boston         |
| New York       |
| White Plains   |
| Hickville      |
| Atlanta        |
| Madison        |
| Paxton         |
| Dallas         |
| Denver         |
| Salt Lake City |
| Los Angeles    |
| San Diego      |
| San Francisco  |
| Seattle        |
+----------------+
15 rows in set (0,01 sec)*/

/* Question 10*/
SELECT name, color FROM jbparts WHERE weight > (SELECT weight FROM jbparts WHERE name = 'card reader');
/*+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0,00 sec)*/

/* Question 11*/
SELECT p1.name, p1.color FROM jbparts p1 JOIN jbparts p2 ON p1.weight > p2.weight and p2.name ='card reader';
/*+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0,00 sec)*/

/* Question 12*/
SELECT AVG(weight) FROM jbparts WHERE color = 'black';
/*+-------------+
| AVG(weight) |
+-------------+
|    347.2500 |
+-------------+
1 row in set (0,00 sec)*/

/* Question 13*/
SELECT s.name, SUM(p.weight * sp.quan) AS total_weight 
FROM jbsupplier s 
JOIN jbsupply sp ON s.id = sp.supplier 
JOIN jbparts p ON sp.part = p.id
JOIN jbcity c ON s.city = c.id
WHERE c.state = 'Mass'
GROUP BY s.name;
/*+--------------+--------------+
| name         | total_weight |
+--------------+--------------+
| DEC          |         3120 |
| Fisher-Price |      1135000 |
+--------------+--------------+
2 rows in set (0,00 sec)*/

/* Question 14*/
CREATE TABLE labitems(
    id integer,
    name varchar(255),
    dept integer,
    price integer,
    qoh integer,
    supplier integer,
    constraint pk_labitems
        primary key (id),
    constraint fk1_labitems
        FOREIGN KEY (dept) references jbdept(id), 
    constraint fk2_labitems
      FOREIGN KEY (supplier) references jbsupplier(id) 
);

INSERT INTO labitems   
SELECT * FROM jbitem WHERE price < (SELECT AVG(price) FROM jbitem);

SELECT * FROM labitems;
/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0,00 sec)*/



/* Question 15*/

CREATE VIEW items_view AS
SELECT *
FROM jbitem
WHERE price < (SELECT AVG(price) FROM jbitem);
/*Query OK, 0 rows affected (0,00 sec)*/
SELECT * FROM items_view;
/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+*/

/* Question 16*/
/*The difference is that a table is static which mean that it stores data on a physical disk,
and it remains stored until it's explicitly changed. 
A view on the otherhand is dynamic which mean that they do not store the data it shows.
Instead a view shows a dynamic result based on the current state of underlying data from a table, every time it's queried.

/* Question 17*/
 CREATE VIEW debit_total_cost AS
 SELECT jbsale.debit AS debit_id,
        SUM(jbitem.price * jbsale.quantity) AS total_cost
 FROM jbsale, jbitem
 WHERE jbsale.item = jbitem.id
 GROUP BY jbsale.debit;
 
 SELECT * FROM debit_total_cost;
 
/*+----------+------------+
| debit_id | total_cost |
+----------+------------+
|   100581 |       2050 |
|   100586 |      13446 |
|   100592 |        650 |
|   100593 |        430 |
|   100594 |       3295 |
+----------+------------+
5 rows in set (0,00 sec)*/


/* Question 18*/
CREATE VIEW debit_total_cost AS
 SELECT jbsale.debit AS debit_id,
        SUM(jbitem.price * jbsale.quantity) AS total_cost
FROM jbsale
INNER JOIN jbitem ON jbsale.item = jbitem.id
GROUP BY jbsale.debit;
SELECT * FROM debit_total_cost;

/* We use inner join since we only want the columns from jbitem that's also already in jbsale.
Since we want to show by debit, which is in the jbsale table.*/

SELECT * FROM debit_total_cost;
/*+----------+------------+
| debit_id | total_cost |
+----------+------------+
|   100581 |       2050 |
|   100586 |      13446 |
|   100592 |        650 |
|   100593 |        430 |
|   100594 |       3295 |
+----------+------------+
5 rows in set (0,00 sec)*/


/* Question 19*/
/* a) */
/*DELETE FROM jbsupplier 
WHERE city IN (SELECT id FROM jbcity WHERE name = 'Los Angeles');*/
/*Error occurs*/

DELETE FROM jbsale
WHERE item IN(SELECT id FROM jbitem WHERE supplier IN (SELECT id FROM jbsupplier WHERE city IN (SELECT id FROM jbcity WHERE name = 'Los Angeles')));
/*Query OK, 1 row affected (0,00 sec)*/

DELETE FROM jbitem WHERE supplier IN (SELECT id FROM jbsupplier WHERE city IN (SELECT id FROM jbcity WHERE name = 'Los Angeles'));
/*Query OK, 2 rows affected (0,01 sec)*/
DELETE FROM jbsupplier WHERE city IN (SELECT id FROM jbcity WHERE name = 'Los Angeles');
/*Query OK, 1 row affected (0,00 sec)*/
SELECT * FROM jbsupplier;/*
+-----+--------------+------+
| id  | name         | city |
+-----+--------------+------+
|   5 | Amdahl       |  921 |
|  15 | White Stag   |  106 |
|  20 | Wormley      |  118 |
|  33 | Levi-Strauss |  941 |
|  42 | Whitman's    |  802 |
|  62 | Data General |  303 |
|  67 | Edger        |  841 |
|  89 | Fisher-Price |   21 |
| 122 | White Paper  |  981 |
| 125 | Playskool    |  752 |
| 213 | Cannon       |  303 |
| 241 | IBM          |  100 |
| 440 | Spooley      |  609 |
| 475 | DEC          |   10 |
| 999 | A E Neumann  |  537 |
+-----+--------------+------+
15 rows in set (0,00 sec)

/*b) We looked at the ER diagram and saw that the supplier also has a relation with item. 
When we tried to delete the item we got an error and noticed that item has a multivalued sale attribute 
We therefore started with deleting the item in jbsale, then deleted item in supplier before we could delete the supplier form jbsupplier*/

/* Question 20*/

CREATE VIEW jbsale_supply(supplier, item, quantity) AS
SELECT jbsupplier.name, jbitem.name, jbsale.quantity
FROM jbsupplier, jbitem, jbsale
WHERE jbsupplier.id = jbitem.supplier
AND jbsale.item = jbitem.id;
/*Query OK, 0 rows affected (0,01 sec)*/

SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
GROUP BY supplier;

/*+--------------+------+
| supplier     | sum  |
+--------------+------+
| Cannon       |    6 |
| Levi-Strauss |    1 |
| Playskool    |    2 |
| White Stag   |    4 |
| Whitman's    |    2 |
+--------------+------+
5 rows in set (0,00 sec)*/

DROP VIEW jbsale_supply;
/*Query OK, 0 rows affected (0,00 sec)*/


CREATE VIEW jbsale_supply(SupplierName,ItemName,quantity) AS
SELECT jbsupplier.name, jbitem.name, jbsale.quantity
FROM jbsupplier
INNER JOIN jbitem ON jbsupplier.id = jbitem.supplier
LEFT JOIN jbsale ON jbsale.item = jbitem.id;


SELECT SupplierName, sum(quantity) FROM jbsale_supply
GROUP BY SupplierName;

/*+--------------+---------------+
| SupplierName | sum(quantity) |
+--------------+---------------+
| Cannon       |             6 |
| Fisher-Price |          NULL |
| Levi-Strauss |             1 |
| Playskool    |             2 |
| White Stag   |             4 |
| Whitman's    |             2 |
+--------------+---------------+
6 rows in set (0.01 sec)*/















