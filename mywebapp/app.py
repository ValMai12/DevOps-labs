from flask import Flask, jsonify, request
import argparse
import pymysql

app = Flask(__name__)
config = {}


def get_db_connection():
    return pymysql.connect(
        host=config["db_host"],
        user=config["db_user"],
        password=config["db_password"],
        database=config["db_name"],
        port=config["db_port"],
        cursorclass=pymysql.cursors.DictCursor
    )


def wants_json():
    accept_header = request.headers.get("Accept", "")
    return "application/json" in accept_header


@app.route("/")
def home():
    return """
    <h1>mywebapp</h1>

    <h2>Available endpoints</h2>

    <ul>
        <li>GET /notes</li>
        <li>POST /notes</li>
        <li>GET /notes/&lt;id&gt;</li>
        <li>GET /health/alive</li>
        <li>GET /health/ready</li>
    </ul>
    """


@app.route("/health/alive")
def alive():
    return "OK", 200


@app.route("/health/ready")
def ready():

    try:
        connection = get_db_connection()
        connection.close()

        return "OK", 200

    except Exception as error:
        return f"Database error: {error}", 500


@app.route("/notes", methods=["GET"])
def get_notes():

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT id, title FROM notes")

    notes = cursor.fetchall()

    connection.close()

    if wants_json():
        return jsonify(notes)

    html = """
    <h1>Notes</h1>

    <table border="1">
        <tr>
            <th>ID</th>
            <th>Title</th>
        </tr>
    """

    for note in notes:
        html += f"""
        <tr>
            <td>{note["id"]}</td>
            <td>{note["title"]}</td>
        </tr>
        """

    html += "</table>"

    return html


@app.route("/notes/<int:note_id>", methods=["GET"])
def get_note(note_id):

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute(
        "SELECT * FROM notes WHERE id = %s",
        (note_id,)
    )

    note = cursor.fetchone()

    connection.close()

    if not note:
        return {"error": "Note not found"}, 404

    if wants_json():
        return jsonify(note)

    return f"""
    <h1>{note["title"]}</h1>

    <p><b>ID:</b> {note["id"]}</p>

    <p><b>Created at:</b> {note["created_at"]}</p>

    <p>{note["content"]}</p>
    """


@app.route("/notes", methods=["POST"])
def create_note():

    data = request.get_json(silent=True)

    if not data:
        return {"error": "JSON body is required"}, 400

    title = data.get("title")
    content = data.get("content")

    if not title or not content:
        return {"error": "title and content are required"}, 400

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute(
        """
        INSERT INTO notes (title, content)
        VALUES (%s, %s)
        """,
        (title, content)
    )

    connection.commit()

    note_id = cursor.lastrowid

    connection.close()

    return jsonify({
        "id": note_id,
        "title": title,
        "content": content
    }), 201


def load_config():
    parser = argparse.ArgumentParser()

    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=3000)

    parser.add_argument("--db-host", default=None)
    parser.add_argument("--db-port", type=int, default=3306)
    parser.add_argument("--db-user", default=None)
    parser.add_argument("--db-password", default=None)
    parser.add_argument("--db-name", default=None)

    args, _ = parser.parse_known_args()

    import os

    config["db_host"] = args.db_host or os.getenv("MYWEBAPP_DB_HOST")
    config["db_port"] = args.db_port
    config["db_user"] = args.db_user or os.getenv("MYWEBAPP_DB_USER")
    config["db_password"] = (
        args.db_password
        or os.getenv("MYWEBAPP_DB_PASSWORD")
    )
    config["db_name"] = args.db_name or os.getenv("MYWEBAPP_DB_NAME")

    return args


load_config()


if __name__ == "__main__":
    args = load_config()
    app.run(
        host=args.host,
        port=args.port
    )
