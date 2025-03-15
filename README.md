# Movie Revenue Prediction & Database Integration

This project is a **Movie Database System** with an integrated **Machine Learning prediction engine**. It combines **Relational Databases (MySQL)**, **NoSQL (MongoDB)**, and a **FastAPI-based API**, topped with a **Movie Revenue Prediction ML model**. 

The system fetches the latest movie data, preprocesses it, and predicts whether the movie will achieve **High** or **Low Revenue** based on historical data.

## Tech Stack
| Technology | Description                       |
|------------|-----------------------------------|
| **MySQL**  | Relational database for storing movie, director, and genre data |
| **MongoDB**| NoSQL database for flexible storage (optional implementation) |
| **FastAPI**| Backend API to perform CRUD operations and prediction logging |
| **Python** | Data handling, ML modeling, API communication |
| **Scikit-learn** | ML model creation and prediction |
| **Pydantic** | Data validation in FastAPI |
| **Seaborn / Matplotlib** | Visualizations for analysis and error tracking |

## Features & Tasks
### Task 1 - Database Implementation  
- **MySQL** relational database with normalized schema (3NF).  
- **MongoDB** collections for NoSQL implementation (optional).  
- Created **stored procedures** and **triggers** for validation and logging in SQL.  
- **Entity-Relationship Diagram (ERD)** provided.

### Task 2 - FastAPI CRUD Operations  
- CRUD endpoints for:
  - `/movies/`  
  - `/directors/`  
  - `/genres/`
- Deployed API on **Render** [`https://pipeline-databasedesign.onrender.com/`](https://pipeline-databasedesign.onrender.com/).  
- Input validation using **Pydantic**.

### Task 3 - Fetch, Predict & Log  
- Fetch **latest movie** via `/movies/` API endpoint.  
- Preprocess data (handle missing values).  
- Train & Use **ML model** (`movie_model.pkl`) to predict **High** or **Low Revenue**.  
- Log prediction results directly to MySQL database.  
- Evaluate Performance with **classification report** (precision, recall, F1-score), **confusion matrix** for error analysis and **feature importance bar chart** to understand influential factors.
- Visualize results using **scatter plot** and **correlation heatmap** to assess feature correlations

## Database Schema
### Tables
- **Movies** (`movie_id`, `title`, `year`, `score`, `metascore`, `votes`, `director_id`, `runtime`, `revenue`, `description`)  
- **Genres** (`genre_id`, `name`)  
- **MovieGenres** (mapping table: `movie_id`, `genre_id`)  
- **Directors** (`director_id`, `name`, `birth_date`, `nationality`)  
- **MovieAuditLog** (logging table for updates to Movies)

**Stored Procedure**: Automatically categorize movies based on revenue.  
**Trigger**: Validate metascore before insert (must be between 0 and 100).

## Setup & Installation
1. **Clone this repo**  
   ```bash
   git clone https://github.com/mutabazichristian/pipeline.git
   ```

2. **MySQL Setup**  
   - Run SQL schema scripts in MySQL Workbench or CLI.  
   - Tables: Movies, Directors, Genres, MovieGenres.  
   - Stored Procedures & Triggers included.

3. **MongoDB Setup (Optional)**  
   - Import collections using MongoDB Compass or CLI.

4. **Run FastAPI Server Locally**  
   ```bash
   uvicorn main:app --reload
   ```

5. **Test API Endpoints**  
   - Access via Swagger UI: [`http://127.0.0.1:8000/docs`](http://127.0.0.1:8000/docs) 
   - Deployed URL (Render): [`https://pipeline-databasedesign.onrender.com`](https://pipeline-databasedesign.onrender.com)

## ML Model (Movie Revenue Prediction)
1. **Data Preprocessing**  
   - `movies.csv` dataset cleaned (handled missing values in `Score`, `Metascore`, `Votes`, `Runtime` using mean imputation where needed).
   - Features used: `Score`, `Metascore`, `Votes`, `Runtime`.  
   - Target: `high_revenue` (1 if Revenue > 100, else 0).

2. **Model Training**  
   - Used `RandomForestClassifier` for binary classification (High/Low Revenue).
   - Accuracy: `94%` on test data.
   - Saved trained model as `movie_model.pkl`.

3. **Prediction & Logging Script**  
   - Fetch latest movie again from API.  
   - Preprocess extracted features/data to match the model’s input format.
   - Predict revenue category (High/Low) using the trained model.
   - Log predictions directly into the MySQL database via an API call `(PUT /movies/{movie_id})` to update the movie data, including the prediction, in the database.

## Contributions

- Christian Mutabazi - Task 1
- Theodora Omunizua - Task 2
- Eunice Adewusi - Task 3
