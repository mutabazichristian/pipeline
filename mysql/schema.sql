-- Create database
CREATE DATABASE movie_db;
USE movie_db;

-- Directors table
CREATE TABLE Directors (
    director_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50)
);

-- Movies table
CREATE TABLE Movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT,
    score DECIMAL(3,1),
    metascore INT,
    votes INT DEFAULT 0,
    director_id INT,
    runtime INT,
    revenue DECIMAL(12,2),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (director_id) REFERENCES Directors(director_id)
);

-- Genres table
CREATE TABLE Genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Movie_Genres junction table
CREATE TABLE Movie_Genres (
    movie_genre_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT,
    genre_id INT,
    UNIQUE(movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) ON DELETE CASCADE
);

-- audit log table
CREATE TABLE Movie_Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_title VARCHAR(255),
    new_title VARCHAR(255),
    old_score DECIMAL(3,1),
    new_score DECIMAL(3,1)
);

-- stored procedure
DELIMITER //
CREATE PROCEDURE add_movie(
    IN p_title VARCHAR(255),
    IN p_year INT,
    IN p_score DECIMAL(3,1),
    IN p_director_id INT,
    IN p_metascore INT,
    IN p_runtime INT,
    IN p_revenue DECIMAL(12,2),
    IN p_description TEXT
)
BEGIN
    INSERT INTO Movies (title, year, score, metascore, director_id, runtime, revenue, description)
    VALUES (p_title, p_year, p_score, p_metascore, p_director_id, p_runtime, p_revenue, p_description);
END //
DELIMITER ;

-- trigger to log changes
DELIMITER //
CREATE TRIGGER movie_update_trigger
AFTER UPDATE ON Movies
FOR EACH ROW
BEGIN
    IF (OLD.title <> NEW.title OR OLD.score <> NEW.score) THEN
        INSERT INTO Movie_Audit_Log (movie_id, action_type, old_title, new_title, old_score, new_score)
        VALUES (NEW.movie_id, 'UPDATE', OLD.title, NEW.title, OLD.score, NEW.score);
    END IF;
END //
DELIMITER ;

-- indexingg
CREATE INDEX idx_movies_title ON Movies(title);
CREATE INDEX idx_movies_year ON Movies(year);
CREATE INDEX idx_movies_score ON Movies(score);
CREATE INDEX idx_directors_name ON Directors(name);
