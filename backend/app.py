import sys
import os

# Windows terminali için UTF-8 encoding zorla
try:
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
except Exception:
    pass

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from flask import Flask, send_from_directory
from flask_cors import CORS
from routes.upload_routes import upload_bp
from routes.analiz_routes import analiz_bp
from routes.pipeline_routes import pipeline_bp
from routes.auth_routes import auth_bp

FRONTEND_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "frontend")

app = Flask(__name__, static_folder=FRONTEND_DIR, static_url_path="")
CORS(app)

# Ana sayfa → index.html'i sun
@app.route("/")
def index():
    return send_from_directory(FRONTEND_DIR, "index.html")

@app.route("/<path:filename>")
def static_files(filename):
    return send_from_directory(FRONTEND_DIR, filename)

# Yüklenen dosyalar için geçici klasör
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), "uploads_temp")
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
app.config["MAX_CONTENT_LENGTH"] = 50 * 1024 * 1024  # 50 MB limit

# Route blueprint'lerini kayıt et
app.register_blueprint(upload_bp,    url_prefix="/api")
app.register_blueprint(analiz_bp,    url_prefix="/api")
app.register_blueprint(pipeline_bp,  url_prefix="/api")
app.register_blueprint(auth_bp,      url_prefix="/api")

if __name__ == "__main__":
    print("==============================================")
    print("  E-Ticaret Mutabakat API Baslatiliyor...")
    print("  http://localhost:5000")
    print("==============================================")
    app.run(debug=True, port=5000)
