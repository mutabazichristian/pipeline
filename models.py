from pydantic import BaseModel
from typing import Optional
from datetime import date

class Director(BaseModel):
    director_id: Optional[int] = None
    name: str

class Movie(BaseModel):
    movie_id: Optional[int] = None
    title: str
    year: Optional[int] = None
    score: Optional[float] = None
    metascore: Optional[int] = None
    votes: Optional[int] = None
    director_id: Optional[int] = None
    runtime: Optional[int] = None
    revenue: Optional[float] = None
    description: Optional[str] = None

class Genre(BaseModel):
    genre_id: Optional[int] = None
    name: str

class MovieGenre(BaseModel):
    movie_genre_id: Optional[int] = None
    movie_id: int
    genre_id: int

class MovieAuditLog(BaseModel):
    log_id: Optional[int] = None
    movie_id: int
    action_type: str
    action_timestamp: Optional[str] = None
    old_title: Optional[str] = None
    new_title: Optional[str] = None
    old_score: Optional[float] = None
    new_score: Optional[float] = None
    user_name: Optional[str] = None