from flask import Flask

app = Flask(__name__)


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


@app.route("/notes")
def notes():
    return """
    <h1>Notes</h1>

    <table border="1">
        <tr>
            <th>ID</th>
            <th>Title</th>
        </tr>

        <tr>
            <td>1</td>
            <td>First note</td>
        </tr>

        <tr>
            <td>2</td>
            <td>Study DevOps</td>
        </tr>
    </table>
    """


app.run(host="127.0.0.1", port=3000)