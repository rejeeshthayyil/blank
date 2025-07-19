-- MS SQL Server Table Creation Examples
-- This file contains various examples of creating tables in MS SQL Server

-- 1. Basic table with common data types
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    HireDate DATE NOT NULL DEFAULT GETDATE(),
    Salary DECIMAL(10,2),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- 2. Table with foreign key relationships
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
    ManagerID INT,
    Budget MONEY,
    Location NVARCHAR(100)
);

-- Add foreign key constraint to Employees table
ALTER TABLE Employees 
ADD DepartmentID INT,
CONSTRAINT FK_Employees_Department 
FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID);

-- Add self-referencing foreign key to Departments
ALTER TABLE Departments
ADD CONSTRAINT FK_Departments_Manager
FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID);

-- 3. Table with check constraints
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    ProductCode NVARCHAR(20) NOT NULL UNIQUE,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Quantity INT NOT NULL CHECK (Quantity >= 0),
    Category NVARCHAR(50) NOT NULL,
    Description NTEXT,
    Weight FLOAT CHECK (Weight > 0),
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Inactive', 'Discontinued')),
    CreatedDate DATETIME2 DEFAULT GETUTCDATE()
);

-- 4. Table with computed columns
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2 DEFAULT GETUTCDATE(),
    Subtotal DECIMAL(10,2) NOT NULL,
    TaxRate DECIMAL(5,4) DEFAULT 0.0825,
    TaxAmount AS (Subtotal * TaxRate) PERSISTED,
    Total AS (Subtotal + (Subtotal * TaxRate)) PERSISTED,
    ShippingAddress NVARCHAR(255),
    OrderStatus NVARCHAR(20) DEFAULT 'Pending' CHECK (OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'))
);

-- 5. Table with GUID primary key
CREATE TABLE Customers (
    CustomerID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    Address NVARCHAR(255),
    City NVARCHAR(50),
    State NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50) DEFAULT 'USA',
    Phone NVARCHAR(20),
    Fax NVARCHAR(20),
    Email NVARCHAR(100),
    Website NVARCHAR(100),
    CreditLimit MONEY DEFAULT 5000.00,
    CustomerSince DATE DEFAULT GETDATE()
);

-- 6. Junction table for many-to-many relationship
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0),
    Discount DECIMAL(5,4) DEFAULT 0.00 CHECK (Discount >= 0 AND Discount < 1),
    LineTotal AS (Quantity * UnitPrice * (1 - Discount)) PERSISTED,
    CONSTRAINT FK_OrderDetails_Order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT UK_OrderDetails_OrderProduct UNIQUE (OrderID, ProductID)
);

-- 7. Table with temporal data (System-Versioned)
CREATE TABLE EmployeeHistory (
    EmployeeID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Position NVARCHAR(100),
    Salary DECIMAL(10,2),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistoryArchive));

-- 8. Table with XML data type
CREATE TABLE ProductCatalog (
    CatalogID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    CatalogData XML NOT NULL,
    CatalogName NVARCHAR(100) NOT NULL,
    LastUpdated DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_ProductCatalog_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 9. Table with JSON data (SQL Server 2016+)
CREATE TABLE UserPreferences (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Preferences NVARCHAR(MAX) CHECK (ISJSON(Preferences) = 1),
    Settings NVARCHAR(MAX) CHECK (ISJSON(Settings) = 1),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- 10. Table with advanced indexing
CREATE TABLE AuditLog (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,
    Operation NVARCHAR(10) NOT NULL CHECK (Operation IN ('INSERT', 'UPDATE', 'DELETE')),
    UserName NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
    Timestamp DATETIME2 DEFAULT GETUTCDATE(),
    OldValues NVARCHAR(MAX),
    NewValues NVARCHAR(MAX),
    RecordID NVARCHAR(50)
);

-- Create non-clustered indexes for better performance
CREATE NONCLUSTERED INDEX IX_AuditLog_TableName_Timestamp 
ON AuditLog (TableName, Timestamp);

CREATE NONCLUSTERED INDEX IX_AuditLog_UserName 
ON AuditLog (UserName);

-- Example of creating a table with a composite primary key
CREATE TABLE EmployeeProjects (
    EmployeeID INT NOT NULL,
    ProjectID INT NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    HoursAllocated DECIMAL(5,2),
    HoursWorked DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (EmployeeID, ProjectID),
    CONSTRAINT FK_EmployeeProjects_Employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT CHK_EmployeeProjects_Dates CHECK (EndDate IS NULL OR EndDate >= StartDate),
    CONSTRAINT CHK_EmployeeProjects_Hours CHECK (HoursWorked <= HoursAllocated OR HoursAllocated IS NULL)
);

-- Example with columnstore index (for data warehousing scenarios)
CREATE TABLE SalesData (
    SaleID BIGINT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    SaleDate DATE NOT NULL,
    ProductID INT NOT NULL,
    CustomerID UNIQUEIDENTIFIER NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalAmount DECIMAL(12,2) NOT NULL,
    SalesPersonID INT,
    Region NVARCHAR(50),
    INDEX CCI_SalesData CLUSTERED COLUMNSTORE
);