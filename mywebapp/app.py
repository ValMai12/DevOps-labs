from flask import Flask, jsonify, request

app = Flask(__name__)

notes = [
    {
        "id": 1,
        "title": "First note",
        "content": "Hello from mywebapp"
    },
    {
        "id": 2,
        "title": "Study DevOps",
        "content": "Finish laboratory work"
    }
]


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
    return "OK", 200


@app.route("/notes", methods=["GET"])
def get_notes():

    if wants_json():
        result = []

        for note in notes:
            result.append({
                "id": note["id"],
                "title": note["title"]
            })

        return jsonify(result)

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

    for note in notes:

        if note["id"] == note_id:

            if wants_json():
                return jsonify(note)

            return f"""
            <h1>{note["title"]}</h1>

            <p><b>ID:</b> {note["id"]}</p>

            <p>{note["content"]}</p>
            """

    return {"error": "Note not found"}, 404


@app.route("/notes", methods=["POST"])
def create_note():

    data = request.get_json()

    if not data:
        return {"error": "JSON body is required"}, 400

    title = data.get("title")
    content = data.get("content")

    if not title or not content:
        return {"error": "title and content are required"}, 400

    new_note = {
        "id": len(notes) + 1,
        "title": title,
        "content": content
    }

    notes.append(new_note)

    return jsonify(new_note), 201


app.run(host="127.0.0.1", port=3000)