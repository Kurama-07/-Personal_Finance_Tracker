-- ============================================================
-- 💰 Personal Finance Tracker SQL
-- ============================================================
-- Author: [Soumavo Acharjee]
-- Date: [15-07-2025]
-- Description: Budget tracking database with users, income,
--              expenses, categories, summary queries, and views.
-- ============================================================

-- 1️⃣ SCHEMA CREATION
-- Users Table
CREATE TABLE Users (
    UserID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserName TEXT NOT NULL,
    Email TEXT UNIQUE
);

-- Categories Table
CREATE TABLE Categories (
    CategoryID INTEGER PRIMARY KEY AUTOINCREMENT,
    CategoryName TEXT NOT NULL
);

-- Income Table
CREATE TABLE Income (
    IncomeID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    Amount REAL,
    IncomeDate DATE,
    Source TEXT,
    FOREIGN KEY(UserID) REFERENCES Users(UserID)
);

-- Expenses Table
CREATE TABLE Expenses (
    ExpenseID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    CategoryID INTEGER,
    Amount REAL,
    ExpenseDate DATE,
    Description TEXT,
    FOREIGN KEY(UserID) REFERENCES Users(UserID),
    FOREIGN KEY(CategoryID) REFERENCES Categories(CategoryID)
);

-- 2️⃣ DUMMY DATA INSERTION

-- Insert Users
INSERT INTO Users (UserName, Email) VALUES ('Alice', 'alice@example.com');
INSERT INTO Users (UserName, Email) VALUES ('Bob', 'bob@example.com');

-- Insert Categories
INSERT INTO Categories (CategoryName) VALUES ('Groceries');
INSERT INTO Categories (CategoryName) VALUES ('Rent');
INSERT INTO Categories (CategoryName) VALUES ('Utilities');
INSERT INTO Categories (CategoryName) VALUES ('Entertainment');

-- Insert Income
INSERT INTO Income (UserID, Amount, IncomeDate, Source) VALUES (1, 50000, '2025-07-01', 'Salary');
INSERT INTO Income (UserID, Amount, IncomeDate, Source) VALUES (2, 60000, '2025-07-01', 'Freelancing');

-- Insert Expenses
INSERT INTO Expenses (UserID, CategoryID, Amount, ExpenseDate, Description) VALUES (1, 1, 5000, '2025-07-02', 'Groceries for July');
INSERT INTO Expenses (UserID, CategoryID, Amount, ExpenseDate, Description) VALUES (1, 2, 15000, '2025-07-03', 'Monthly Rent');
INSERT INTO Expenses (UserID, CategoryID, Amount, ExpenseDate, Description) VALUES (1, 4, 2000, '2025-07-04', 'Movie and snacks');
INSERT INTO Expenses (UserID, CategoryID, Amount, ExpenseDate, Description) VALUES (2, 1, 4500, '2025-07-02', 'Groceries');
INSERT INTO Expenses (UserID, CategoryID, Amount, ExpenseDate, Description) VALUES (2, 3, 3000, '2025-07-05', 'Electricity bill');

-- 3️⃣ SUMMARY QUERIES

-- Monthly Expense Summary per User
SELECT 
    u.UserName,
    strftime('%Y-%m', e.ExpenseDate) AS Month,
    SUM(e.Amount) AS TotalExpenses
FROM Expenses e
JOIN Users u ON e.UserID = u.UserID
GROUP BY u.UserName, Month;

-- Category-wise Spending per User
SELECT 
    u.UserName,
    c.CategoryName,
    SUM(e.Amount) AS TotalSpent
FROM Expenses e
JOIN Users u ON e.UserID = u.UserID
JOIN Categories c ON e.CategoryID = c.CategoryID
GROUP BY u.UserName, c.CategoryName;

-- 4️⃣ VIEW CREATION FOR BALANCE TRACKING

CREATE VIEW UserBalances AS
SELECT 
    u.UserName,
    IFNULL((SELECT SUM(i.Amount) FROM Income i WHERE i.UserID = u.UserID), 0) AS TotalIncome,
    IFNULL((SELECT SUM(e.Amount) FROM Expenses e WHERE e.UserID = u.UserID), 0) AS TotalExpenses,
    IFNULL((SELECT SUM(i.Amount) FROM Income i WHERE i.UserID = u.UserID), 0) -
    IFNULL((SELECT SUM(e.Amount) FROM Expenses e WHERE e.UserID = u.UserID), 0) AS Balance
FROM Users u;

-- 5️⃣ EXPORTABLE REPORT QUERIES

-- View User Balances
SELECT * FROM UserBalances;

-- Monthly Category-wise Expense Report for Export
SELECT 
    u.UserName,
    strftime('%Y-%m', e.ExpenseDate) AS Month,
    c.CategoryName,
    SUM(e.Amount) AS TotalSpent
FROM Expenses e
JOIN Users u ON e.UserID = u.UserID
JOIN Categories c ON e.CategoryID = c.CategoryID
GROUP BY u.UserName, Month, c.CategoryName;
