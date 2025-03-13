from fastapi import FastAPI, HTTPException
from models import Director, Movie, Genre, MovieGenre, MovieAuditLog
from database import execute_query

app = FastAPI()

# Test endpoint
@app.get("/")
def read_root():
    return {"message": "Movie API is running"}

# Director CRUD endpoints
@app.post("/directors/", response_model=Director)
def create_director(director: Director):
    query = "INSERT INTO Directors (name, birth_date, nationality) VALUES (%s, %s, %s)"
    values = (director.name, director.birth_date, director.nationality)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return Director(**director.dict(), director_id=result["message"]["insert_id"])

@app.get("/directors/{director_id}", response_model=Director)
def read_director(director_id: int):
    query = "SELECT * FROM Directors WHERE director_id = %s"
    values = (director_id,)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    if not result:
        raise HTTPException(status_code=404, detail="Director not found")
    return Director(**result[0])

@app.get("/directors/", response_model=list[Director])
def read_directors():
    query = "SELECT * FROM Directors"
    result = execute_query(query)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return [Director(**row) for row in result]

@app.put("/directors/{director_id}", response_model=Director)
def update_director(director_id: int, director: Director):
    query = "UPDATE Directors SET name = %s, birth_date = %s, nationality = %s WHERE director_id = %s"
    values = (director.name, director.birth_date, director.nationality, director_id)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return read_director(director_id)

@app.delete("/directors/{director_id}")
def delete_director(director_id: int):
    query = "DELETE FROM Directors WHERE director_id = %s"
    values = (director_id,)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return {"message": "Director deleted"}

# Movie CRUD endpoints
@app.post("/movies/", response_model=Movie)
def create_movie(movie: Movie):
    query = "INSERT INTO Movies (title, year, score, metascore, votes, director_id, runtime, revenue, description) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
    values = (movie.title, movie.year, movie.score, movie.metascore, movie.votes, movie.director_id, movie.runtime, movie.revenue, movie.description)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return Movie(**movie.dict(), movie_id=result["message"]["insert_id"])

@app.get("/movies/{movie_id}", response_model=Movie)
def read_movie(movie_id: int):
    query = "SELECT * FROM Movies WHERE movie_id = %s"
    values = (movie_id,)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    if not result:
        raise HTTPException(status_code=404, detail="Movie not found")
    return Movie(**result[0])

@app.get("/movies/", response_model=list[Movie])
def read_movies():
    query = "SELECT * FROM Movies"
    result = execute_query(query)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return [Movie(**row) for row in result]

@app.put("/movies/{movie_id}", response_model=Movie)
def update_movie(movie_id: int, movie: Movie):
    query = "UPDATE Movies SET title = %s, year = %s, score = %s, metascore = %s, votes = %s, director_id = %s, runtime = %s, revenue = %s, description = %s WHERE movie_id = %s"
    values = (movie.title, movie.year, movie.score, movie.metascore, movie.votes, movie.director_id, movie.runtime, movie.revenue, movie.description, movie_id)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return read_movie(movie_id)

@app.delete("/movies/{movie_id}")
def delete_movie(movie_id: int):
    query = "DELETE FROM Movies WHERE movie_id = %s"
    values = (movie_id,)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return {"message": "Movie deleted"}

# Genre CRUD endpoints
@app.post("/genres/", response_model=Genre)
def create_genre(genre: Genre):
    query = "INSERT INTO Genres (name) VALUES (%s)"
    values = (genre.name,)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return Genre(**genre.dict(), genre_id=result["message"]["insert_id"])

@app.get("/genres/{genre_id}", response_model=Genre)
def read_genre(genre_id: int):
    query = "SELECT * FROM Genres WHERE genre_id = %s"
    values = (genre_id,)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    if not result:
        raise HTTPException(status_code=404, detail="Genre not found")
    return Genre(**result[0])

@app.get("/genres/", response_model=list[Genre])
def read_genres():
    query = "SELECT * FROM Genres"
    result = execute_query(query)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return [Genre(**row) for row in result]

@app.put("/genres/{genre_id}", response_model=Genre)
def update_genre(genre_id: int, genre: Genre):
    query = "UPDATE Genres SET name = %s WHERE genre_id = %s"
    values = (genre.name, genre_id)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return read_genre(genre_id)

@app.delete("/genres/{genre_id}")
def delete_genre(genre_id: int):
    query = "DELETE FROM Genres WHERE genre_id = %s"
    values = (genre_id,)
    result = execute_query(query, values)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return {"message": "Genre deleted"}