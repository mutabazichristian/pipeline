import mysql.connector

def get_db_connection():
    """Establishes a connection to the MySQL database."""
    try:
        connection = mysql.connector.connect(
            host="movies-345-xpensedb.b.aivencloud.com",
            user="avnadmin",
            password="AVNS_vOOJkylxNhQnGWQgJ3t",
            database="movie_db",
            port=12104
        )
        return connection
    except mysql.connector.Error as err:
        print(f"Error connecting to database: {err}")
        return None

def execute_query(query, values=None):
    """Executes a SQL query and returns the results."""
    connection = get_db_connection()
    if connection:
        cursor = connection.cursor(dictionary=True) # dictionary=true allows for returning dictionaries.
        try:
            cursor.execute(query, values)
            if query.lower().startswith("select"):
                results = cursor.fetchall()
                connection.close()
                return results
            else:
                connection.commit()
                connection.close()
                return {"message": "Query executed successfully"}
        except mysql.connector.Error as err:
            print(f"Error executing query: {err}")
            connection.close()
            return {"error": str(err)}
    return {"error": "Database connection failed"}