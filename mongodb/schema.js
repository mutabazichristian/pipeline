// Create db 
use MovieDB;

// Create collections 
db.createCollection("directors", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["name"],
         properties: {
            name: { bsonType: "string" },
            birth_date: { bsonType: "date" },
            nationality: { bsonType: "string" }
         }
      }
   }
});

db.createCollection("movies", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["title"],
         properties: {
            title: { bsonType: "string" },
            year: { bsonType: "int" },
            score: { bsonType: "double" },
            metascore: { bsonType: "int" },
            votes: { bsonType: "int" },
            director_id: { bsonType: "objectId" },
            runtime: { bsonType: "int" },
            revenue: { bsonType: "double" },
            description: { bsonType: "string" },
            genres: { 
               bsonType: "array",
               items: { bsonType: "objectId" }
            },
            created_at: { bsonType: "date" },
            updated_at: { bsonType: "date" }
         }
      }
   }
});

db.createCollection("genres", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["name"],
         properties: {
            name: { bsonType: "string" }
         }
      }
   }
});

db.createCollection("movie_audit_logs");

// Create indexes
db.movies.createIndex({ title: 1 });
db.movies.createIndex({ year: 1 });
db.movies.createIndex({ score: 1 });
db.directors.createIndex({ name: 1 });
db.genres.createIndex({ name: 1 }, { unique: true });

// Function to simulate a stored procedure
function addMovie(movieData) {
    const now = new Date();
    const movie = {
        title: movieData.title,
        year: movieData.year,
        score: movieData.score,
        metascore: movieData.metascore,
        votes: movieData.votes || 0,
        director_id: movieData.director_id,
        runtime: movieData.runtime,
        revenue: movieData.revenue,
        description: movieData.description,
        genres: movieData.genre_ids || [],
        created_at: now,
        updated_at: now
    };
    
    return db.movies.insertOne(movie);
}

// Function to simulate a trigger for logging
function logMovieChange(movieId, oldValues, newValues) {
    if (oldValues.title !== newValues.title || oldValues.score !== newValues.score) {
        return db.movie_audit_logs.insertOne({
            movie_id: movieId,
            action_type: "UPDATE",
            action_timestamp: new Date(),
            old_title: oldValues.title,
            new_title: newValues.title,
            old_score: oldValues.score,
            new_score: newValues.score
        });
    }
}
