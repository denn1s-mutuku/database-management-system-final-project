-- Database Schema for Library Management System
-- Created using MySQL

-- Drop tables if they exist to allow for easy re-creation
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Book_Authors;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS Publishers;
DROP TABLE IF EXISTS Members;

-- -----------------------------------------------------
-- Table `Publishers`
-- Stores information about book publishers
-- -----------------------------------------------------
CREATE TABLE Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE, -- Publisher name must be unique
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255) UNIQUE -- Publisher email must be unique
);

-- -----------------------------------------------------
-- Table `Authors`
-- Stores information about book authors
-- -----------------------------------------------------
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    -- Optional: Add a UNIQUE constraint on first_name and last_name combined if desired
    -- UNIQUE (first_name, last_name),
    birth_date DATE,
    country VARCHAR(100)
);

-- -----------------------------------------------------
-- Table `Books`
-- Stores information about books
-- -----------------------------------------------------
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(13) NOT NULL UNIQUE, -- ISBN must be unique for each book
    publication_year YEAR,
    genre VARCHAR(100),
    publisher_id INT,
    total_copies INT DEFAULT 1 CHECK (total_copies >= 0), -- Total copies must be non-negative
    available_copies INT DEFAULT 1 CHECK (available_copies >= 0), -- Available copies must be non-negative
    -- available_copies should not exceed total_copies (can be managed by application logic or triggers)

    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) ON DELETE SET NULL -- If a publisher is deleted, set publisher_id to NULL
);

-- -----------------------------------------------------
-- Table `Book_Authors`
-- Linking table for the Many-to-Many relationship between Books and Authors
-- -----------------------------------------------------
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id), -- Composite primary key
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE, -- If a book is deleted, remove the link
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE -- If an author is deleted, remove the link
);

-- -----------------------------------------------------
-- Table `Members`
-- Stores information about library members
-- -----------------------------------------------------
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255) UNIQUE NOT NULL, -- Member email must be unique and is required
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- Table `Loans`
-- Records book loans
-- -----------------------------------------------------
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE, -- NULL if the book has not been returned

    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT, -- Prevent deleting a book if there are active loans
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE, -- If a member is deleted, remove their loan history

    -- Optional: Add a CHECK constraint to ensure due_date is after loan_date
    CHECK (due_date >= loan_date)
);

-- Optional: Add indexes for performance on frequently queried columns
CREATE INDEX idx_book_title ON Books(title);
CREATE INDEX idx_member_email ON Members(email);
CREATE INDEX idx_loan_dates ON Loans(loan_date, due_date);
