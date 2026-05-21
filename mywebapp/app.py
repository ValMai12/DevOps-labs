from flask import Flask, jsonify, request
import pymysql

app = Flask(__name__)


def get_db_connection():
    return pymysql.connect(
        host="127.0.0.1",
        user="mywebapp",
        password="mypassword",
        database="mywebapp",
        port=3306,
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

    data = request.get_json()

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


app.run(host="127.0.0.1", port=3000)