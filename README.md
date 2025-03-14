# Database Design and API Integration

This task involves the design and implementation of databases (SQL and MongoDB), creating FastAPI endpoints for CRUD operations, and integrating a machine learning model to fetch data and make predictions.

## Project Structure

The project is divided into the following tasks:

### Task 1: Database Design and Implementation
- Designed and implemented a relational database using [MySQL/PostgreSQL/SQLite] with at least three tables.
- Implemented **primary and foreign keys** to define relationships.
- Implemented a **stored procedure** for automating database operations.
- Created a **trigger** to automate tasks like data validation and logging changes.
- Designed MongoDB collections to model relationships and denormalized data for NoSQL implementation.
- Created an **ERD Diagram** using [tool name], showing the schema and relationships between tables and collections.

### Task 2: API Endpoints for CRUD Operations
- Developed **FastAPI** endpoints to perform CRUD operations on the relational database.
  - **POST**: Create new records.
  - **GET**: Read data from the database.
  - **PUT**: Update existing records.
  - **DELETE**: Remove records.
- Implemented **input validation** using Pydantic models in FastAPI.

### Task 3: Script for Data Fetching and Prediction
- Developed a script to fetch the latest data entry using the **GET** API endpoint.
- Preprocessed the data to handle missing values and ensure it was in the correct format.
- Loaded the pre-trained machine learning model and used it to make predictions based on the fetched data.
- Logged the prediction results back into the database for future reference.

## Contributions

- Christian Mutabazi - Task 1
- Theodora Omunizua - Task 2
- Eunice Adewusi - Task 3
