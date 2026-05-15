-- # Bölüm-1: Veri Tabanı Tasarımı

-- İlk olarak DB kurulumumuzu yapalım.
-- 'CREATE DATABASE' bize bir veritabanı oluşturur.
CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- Tablo Gereksinimlerini sağlayalım.
-- 'CREATE TABLE' ile ihtiyacımız olan tabloları oluşturuyoruz.

CREATE TABLE Categories (
                            CategoryID INT IDENTITY(1,1) PRIMARY KEY,
                            CategoryName VARCHAR(50) NOT NULL
);


CREATE TABLE Products (
                          ProductID INT IDENTITY(1,1) PRIMARY KEY,
                          ProductName VARCHAR(100) NOT NULL,
                          Price DECIMAL(10,2),
                          Stock INT DEFAULT 0,
                          CategoryID INT NOT NULL,

                          CONSTRAINT FK_Products_Categories
                              FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Customers (
                           CustomerID INT IDENTITY(1,1) PRIMARY KEY,
                           FullName VARCHAR(50),
                           City VARCHAR(20),
                           Email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Orders (
                        OrderID INT IDENTITY(1,1) PRIMARY KEY,
                        CustomerID INT NOT NULL,
                        OrderDate DATETIME DEFAULT GETDATE(),
                        TotalAmount DECIMAL(10,2),

                        CONSTRAINT FK_Orders_Customers
                            FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
                              DetailID INT IDENTITY(1,1) PRIMARY KEY,
                              OrderID INT NOT NULL,
                              ProductID INT NOT NULL,
                              Quantity INT,

                              CONSTRAINT FK_OrderDetails_Orders
                                  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),

                              CONSTRAINT FK_OrderDetails_Products
                                  FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Oluşturduğumuz tabloları görmek ve varlığını kontrol etmek için.
-- Sonuçta 5 tane oluşturduğumuz tablo olmalı
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';


-- # Bölüm-2: Veri Girişi

-- Görev-1: 5 adet kategori eklemek.
INSERT INTO Categories (CategoryName)
VALUES
    ('Elektronik'),
    ('Giyim'),
    ('Kitap'),
    ('Kozmetik'),
    ('Ev ve Yaşam');

-- Görev-2: Her kategoriye ait olacak şekilde ürün ekleme
INSERT INTO Products(ProductName, Price, Stock, CategoryID)
VALUES
    ('Airpods Pro', 10000,25,1),
    ('Apple Watch', 8999, 15, 1),
    ('Laptop Çantası', 549.90, 30, 1),

    ('Erkek Tişört', 550, 50, 2),
    ('Kadın Mont', 3000, 20, 2),

    ('Learning SQL', 2200, 40, 3),
    ('SQL Herkes İçin', 960, 35, 3),

    ('Parfüm', 749.90, 18, 4),
    ('Cilt Bakım Kremi', 960, 22, 4),

    ('Masa Lambası', 899.90, 28, 5),
    ('Kahve Makinesi', 2199.90, 10, 5),
    ('Yastık Seti', 499.90, 16, 5);

-- Şimdi ise basit sorgular ile gerçekten ürünler gelmiş mi kontrol edelim.
SELECT *
FROM Products;

-- Görev-3: Müşteri Kayıtları
INSERT INTO Customers(FullName, City, Email)
VALUES
    ('Melih Şişkular','Edirne','melihsiskular@gmail.com'),
    ('Zeynep Kaya', 'Ankara', 'zeynep.kaya@example.com'),
    ('Mehmet Demir', 'İzmir', 'mehmet.demir@example.com'),
    ('Elif Çelik', 'Bursa', 'elif.celik@example.com'),
    ('Can Arslan', 'Edirne', 'can.arslan@example.com'),
    ('Ayşe Şahin', 'Antalya', 'ayse.sahin@example.com');


-- Görev-4: Farklı Tarihlerde Yapılmış Siparişler Ve Detayları

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
    (1, '2025-01-10', 10000.00),
    (2, '2025-01-15', 9549.00),
    (3, '2025-02-05', 2200.00),
    (4, '2025-02-20', 3960.00),
    (5, '2025-03-03', 2199.90),
    (6, '2025-03-18', 2419.90),
    (1, '2025-04-02', 749.90),
    (3, '2025-04-15', 1100.00),
    (2, '2025-05-01', 899.90),
    (5, '2025-05-10', 8999.00);


INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
    -- Sipariş 1
    (1, 1, 1),
    -- Sipariş 2
    (2, 4, 1),
    (2, 2, 1),
    -- Sipariş 3
    (3, 6, 1),
    -- Sipariş 4
    (4, 5, 1),
    (4, 9, 1),
    -- Sipariş 5
    (5, 11, 1),
    -- Sipariş 6
    (6, 7, 2),
    (6, 12, 1),
    -- Sipariş 7
    (7, 8, 1),
    -- Sipariş 8
    (8, 4, 2),
    -- Sipariş 9
    (9, 10, 1),
    -- Sipariş 10
    (10, 2, 1);


-- Tekrar ufak bir kontrol için basit sorgular.
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

-- # Bölüm-3: Sorgulama Ve Analiz

-- 1. Temel Listeleme
-- Stok Miktarı 20'den az olan ürünlerin isimlerini azalan sırada göstermek.
Select ProductName, Stock
From Products
WHERE Stock < 20
ORDER BY Stock DESC;

-- 2. Veri Birleştirme
-- Hangi Müşteri hangi şehirden ne zaman sipariş vermiş ne kadar harcamış.
Select FullName, City, OrderDate, TotalAmount
FROM Customers
         INNER JOIN Orders O on Customers.CustomerID = O.CustomerID;

-- 3. Çoklu Birleştirme Ve Detay Raporu
-- 'Melih Şişkular' isimli müşterinin aldığı ürünün adu, fiyatı ve kategorisini göstermek.
SELECT FullName,ProductName,Price,CategoryName
From Customers
         JOIN Orders O on Customers.CustomerID = O.CustomerID
         JOIN OrderDetails OD on O.OrderID = OD.OrderID
         JOIN Products P on P.ProductID = OD.ProductID
         JOIN Categories C on C.CategoryID = P.CategoryID
WHERE Customers.FullName = 'Melih Şişkular';

--4. Gruplama ve Aggregate Fonksiyonlar
-- Her kategori için kaçar tane ürün olduğunu bulmak
SELECT CategoryName,COUNT(Products.ProductID) AS TotalProduct
FROM Categories
         LEFT JOIN Products on Categories.CategoryID = PRODUCTS.CategoryID
GROUP BY CategoryName;

--5. Ciro Analizi
-- Her müşteriden kazanılan ciroya göre azalan sırada isimleri ve kazandırdıkları cironun gösterimi.
Select FullName, SUM(Price * Quantity) AS Total
FROM Customers
         INNER JOIN Orders O on Customers.CustomerID = O.CustomerID
         INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
         INNER JOIN Products P on P.ProductID = OD.ProductID
GROUP BY FullName
ORDER BY Total DESC;

--6. Zaman Analizi
-- Siparişlerin verildiği zamandan bugüne kadar kaç gün geçti.
SELECT
    OrderID,
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysPassed
FROM Orders;

-- # Bölüm-4: İleri Seviye Veri Tabanı Nesneleri

-- Görev-1: View Oluşturma
CREATE VIEW view_SiparisOzwt AS
SELECT FullName, OrderDate, ProductName,Quantity
From Customers
         Inner Join Orders O on Customers.CustomerID = O.CustomerID
         Inner Join OrderDetails OD on O.OrderID = OD.OrderID
         INNER JOIN Products P on P.ProductID = OD.ProductID;

SELECT *
FROM view_SiparisOzwt;

-- Görev-2: Yedekleme
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT,
MEDIANAME = 'NovaStoreBackup',
NAME = 'NovaStoreDB Full Backup';