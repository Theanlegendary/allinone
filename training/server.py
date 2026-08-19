"""
Training Presentation Server
Serves the training slides and handles image uploads.
Run: python server.py
Then open: http://localhost:5050
"""
from flask import Flask, request, jsonify, send_from_directory, abort
import os, uuid, json
from werkzeug.utils import secure_filename

app = Flask(__name__, static_folder='.', static_url_path='')

BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(BASE_DIR, 'uploads')
ALLOWED    = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'}

def allowed(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED

# ── Static files ─────────────────────────────────────────────────────────────
@app.route('/')
def index():
    return send_from_directory(BASE_DIR, 'index.html')

@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_DIR, filename)

# ── Upload endpoint ──────────────────────────────────────────────────────────
@app.route('/api/upload', methods=['POST'])
def upload():
    slide = request.form.get('slide', 'slide1')
    slot  = request.form.get('slot', '0')           # which grid slot
    files = request.files.getlist('file')
    saved = []
    dest  = os.path.join(UPLOAD_DIR, slide)
    os.makedirs(dest, exist_ok=True)
    for f in files:
        if f and allowed(f.filename):
            ext  = f.filename.rsplit('.', 1)[1].lower()
            name = f"slot_{slot}_{uuid.uuid4().hex[:8]}.{ext}"
            path = os.path.join(dest, name)
            f.save(path)
            saved.append(f'/uploads/{slide}/{name}')
    return jsonify({'ok': True, 'urls': saved})

# ── Delete endpoint ──────────────────────────────────────────────────────────
@app.route('/api/delete', methods=['POST'])
def delete():
    data = request.get_json() or {}
    url  = data.get('url', '')
    # Safety: only allow deleting from uploads/
    rel = url.lstrip('/')
    if not rel.startswith('uploads/'):
        return jsonify({'ok': False, 'error': 'Invalid path'}), 400
    path = os.path.join(BASE_DIR, rel)
    if os.path.isfile(path):
        os.remove(path)
    return jsonify({'ok': True})

# ── List images for a slide ──────────────────────────────────────────────────
@app.route('/api/images/<slide>')
def list_images(slide):
    folder = os.path.join(UPLOAD_DIR, slide)
    if not os.path.isdir(folder):
        return jsonify({'images': []})
    imgs = [
        f'/uploads/{slide}/{fn}'
        for fn in sorted(os.listdir(folder))
        if fn.rsplit('.', 1)[-1].lower() in ALLOWED
    ]
    return jsonify({'images': imgs})

if __name__ == '__main__':
    print("=" * 60)
    print("  Training Presentation Server")
    print("  Open: http://localhost:5050")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5050, debug=False)
