import argparse
import pymysql


parser = argparse.ArgumentParser()

parser.add_argument("--db-host", default="127.0.0.1")
parser.add_argument("--db-port", type=int, default=3306)

parser.add_argument("--db-user", required=True)
parser.add_argument("--db-password", required=True)
parser.add_argument("--db-name", required=True)

args = parser.parse_args()


connection = pymysql.connect(
    host=args.db_host,
    user=args.db_user,
    password=args.db_password,
    database=args.db_name,
    port=args.db_port
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