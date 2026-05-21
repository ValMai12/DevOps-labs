import pymysql


connection = pymysql.connect(
    host="127.0.0.1",
    user="mywebapp",
    password="mypassword",
    database="mywebapp",
    port=3306
)

cursor = connection.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
""")

connection.commit()

print("Migration completed successfully!")

connection.close()