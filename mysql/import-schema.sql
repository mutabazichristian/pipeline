CREATE DATABASE IF NOT EXISTS movie_db;
USE movie_db;

CREATE TABLE IF NOT EXISTS Directors (
    director_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NULL,
    nationality VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS Movies (
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

CREATE TABLE IF NOT EXISTS Genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Movie_Genres (
    movie_genre_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT,
    genre_id INT,
    UNIQUE(movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Movie_Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_title VARCHAR(255),
    new_title VARCHAR(255),
    old_score DECIMAL(3,1),
    new_score DECIMAL(3,1),
    user_name VARCHAR(100)
);

DELIMITER //
CREATE TRIGGER before_insert_movie_audit
BEFORE INSERT ON Movie_Audit_Log
FOR EACH ROW
BEGIN
    SET NEW.user_name = CURRENT_USER();
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS add_movie_with_genres(
    IN p_title VARCHAR(255),
    IN p_year INT,
    IN p_score DECIMAL(3,1),
    IN p_metascore INT,
    IN p_votes INT,
    IN p_director_id INT,
    IN p_runtime INT,
    IN p_revenue DECIMAL(12,2),
    IN p_description TEXT,
    IN p_genres TEXT
)
BEGIN
    DECLARE v_movie_id INT;
    DECLARE v_genre_id INT;
    DECLARE v_genre VARCHAR(50);
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_length INT;
    DECLARE v_delimiter CHAR(1) DEFAULT ',';
    
    START TRANSACTION;
    
    IF p_title != '' THEN
        INSERT INTO Movies (title, year, score, metascore, votes, director_id, runtime, revenue, description)
        VALUES (p_title, p_year, p_score, p_metascore, p_votes, p_director_id, p_runtime, p_revenue, p_description);
        
        SET v_movie_id = LAST_INSERT_ID();
    ELSE
        SELECT MAX(movie_id) INTO v_movie_id FROM Movies;
    END IF;
    
    IF p_genres IS NOT NULL AND p_genres != '' THEN
        genre_loop: LOOP
            SET v_length = LOCATE(v_delimiter, p_genres, v_pos);
            
            IF v_length = 0 THEN
                IF v_pos <= LENGTH(p_genres) THEN
                    SET v_genre = TRIM(SUBSTRING(p_genres, v_pos));
                    
                    SELECT genre_id INTO v_genre_id FROM Genres WHERE name = v_genre LIMIT 1;
                    
                    IF v_genre_id IS NULL THEN
                        INSERT INTO Genres (name) VALUES (v_genre);
                        SET v_genre_id = LAST_INSERT_ID();
                    END IF;
                    
                    INSERT IGNORE INTO Movie_Genres (movie_id, genre_id)
                    VALUES (v_movie_id, v_genre_id);
                END IF;
                
                LEAVE genre_loop;
            END IF;
            
            SET v_genre = TRIM(SUBSTRING(p_genres, v_pos, v_length - v_pos));
            
            SELECT genre_id INTO v_genre_id FROM Genres WHERE name = v_genre LIMIT 1;
           
            IF v_genre_id IS NULL THEN
                INSERT INTO Genres (name) VALUES (v_genre);
                SET v_genre_id = LAST_INSERT_ID();
            END IF;
            
            INSERT IGNORE INTO Movie_Genres (movie_id, genre_id)
            VALUES (v_movie_id, v_genre_id);
            
            SET v_pos = v_length + 1;
        END LOOP;
    END IF;
    
    COMMIT;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER IF NOT EXISTS movie_changes_trigger
BEFORE UPDATE ON Movies
FOR EACH ROW
BEGIN
    IF (OLD.title <> NEW.title OR OLD.score <> NEW.score) THEN
        INSERT INTO Movie_Audit_Log (
            movie_id, 
            action_type, 
            old_title, 
            new_title, 
            old_score, 
            new_score
        )
        VALUES (
            OLD.movie_id, 
            'UPDATE', 
            OLD.title, 
            NEW.title, 
            OLD.score, 
            NEW.score
        );
    END IF;
END //
DELIMITER ;

-- Safe index creation with error handling for older MySQL versions
DELIMITER //
CREATE PROCEDURE create_safe_index()
BEGIN
    DECLARE CONTINUE HANDLER FOR 1061 BEGIN END;  -- Ignore "Index already exists" errors
    
    CREATE INDEX idx_movies_title ON Movies(title);
    CREATE INDEX idx_movies_year ON Movies(year);
    CREATE INDEX idx_movies_score ON Movies(score);
    CREATE INDEX idx_director_name ON Directors(name);
END //
DELIMITER ;

-- Run the index creation procedure
CALL create_safe_index();
DROP PROCEDURE create_safe_index;

CREATE TABLE IF NOT EXISTS temp_movies (
    `Rank` INT,
    Title VARCHAR(255),
    Year INT,
    Score DECIMAL(3,1),
    Metascore INT,
    Genre VARCHAR(255),
    Vote INT,
    Director VARCHAR(100),
    Runtime INT,
    Revenue DECIMAL(12,2),
    Description TEXT
);

DELIMITER //
CREATE PROCEDURE import_from_csv(IN csv_file_path VARCHAR(255))
BEGIN
    SET @load_data_cmd = CONCAT(
        "LOAD DATA INFILE '", 
        csv_file_path, 
        "' INTO TABLE temp_movies ",
        "FIELDS TERMINATED BY ',' ",
        "ENCLOSED BY '\' ",
        "LINES TERMINATED BY '\n' ",
        "IGNORE 1 ROWS;"
    );
    
    PREPARE stmt FROM @load_data_cmd;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    INSERT IGNORE INTO Directors (name)
    SELECT DISTINCT Director FROM temp_movies;
    
    BEGIN
        DECLARE done INT DEFAULT FALSE;
        DECLARE v_rank INT;
        DECLARE v_title VARCHAR(255);
        DECLARE v_year INT;
        DECLARE v_score DECIMAL(3,1);
        DECLARE v_metascore INT;
        DECLARE v_genre VARCHAR(255);
        DECLARE v_vote INT;
        DECLARE v_director VARCHAR(100);
        DECLARE v_runtime INT;
        DECLARE v_revenue DECIMAL(12,2);
        DECLARE v_description TEXT;
        DECLARE v_director_id INT;
        
        DECLARE movie_cursor CURSOR FOR 
            SELECT `Rank`, Title, Year, Score, Metascore, Genre, Vote, Director, Runtime, Revenue, Description 
            FROM temp_movies;
        
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        
        OPEN movie_cursor;
        
        import_loop: LOOP
            FETCH movie_cursor INTO v_rank, v_title, v_year, v_score, v_metascore, v_genre, v_vote, v_director, v_runtime, v_revenue, v_description;
            
            IF done THEN
                LEAVE import_loop;
            END IF;
            
            SELECT director_id INTO v_director_id 
            FROM Directors 
            WHERE name = v_director 
            LIMIT 1;
            
            CALL add_movie_with_genres(
                v_title, 
                v_year,
                v_score, 
                v_metascore, 
                v_vote, 
                v_director_id, 
                v_runtime, 
                v_revenue, 
                v_description, 
                v_genre
            );
        END LOOP;
        
        CLOSE movie_cursor;
    END;
    
    DROP TABLE temp_movies;
END //
DELIMITER ;

CALL import_from_csv('../movies.csv');
