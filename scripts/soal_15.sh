echo "== soal_15: konfigurasi web dinamis di Earendil =="

APPDIR="/var/www/app.K46.com"
APPFILE="${APPDIR}/app.py"
LOGFILE="/var/log/flaskapp.log"
PIDFILE="/var/run/flaskapp.pid"

# 1. Pastikan Python dan Flask terpasang
echo "-- memastikan python3 dan flask tersedia"
apt update -y >/dev/null 2>&1 || true
apt install -y python3 python3-flask >/dev/null 2>&1

# 2. Buat direktori aplikasi
echo "-- membuat direktori aplikasi di ${APPDIR}"
mkdir -p "${APPDIR}"
cd "${APPDIR}"

# 3. Buat file aplikasi Flask sederhana
echo "-- menulis aplikasi Flask"
cat > "${APPFILE}" <<'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return """
    <html>
      <head><title>K46 Dynamic App</title></head>
      <body style='font-family: Arial; text-align: center; margin-top: 10%; background: #f4f4f9;'>
        <h1>Welcome to K46 Dynamic Web App</h1>
        <p>Server: Earendil (192.234.1.2)</p>
        <p>Endpoint: /app</p>
      </body>
    </html>
    """

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

# 4. Hentikan Flask lama jika masih ada
echo "-- menghentikan proses Flask lama (jika ada)"
pkill -f "${APPFILE}" 2>/dev/null || true

# 5. Jalankan Flask manual via nohup
echo "-- menjalankan Flask app di background"
nohup python3 "${APPFILE}" > "${LOGFILE}" 2>&1 & echo $! > "${PIDFILE}"

# 6. Tunggu dan verifikasi
sleep 3
if ss -ltnp | grep -q ':80'; then
  echo "Flask aktif di port 80"
else
  echo "ERROR: Flask belum aktif, cek ${LOGFILE}"
fi

# 7. Tes akses lokal
echo "-- uji akses lokal ke http://localhost/"
curl -I http://localhost || true

echo
echo "Selesai: Flask dynamic app berjalan di Earendil (192.234.1.2, port 80)"
echo "Coba akses http://192.234.1.2/ dari node lain untuk memastikan."

# curl http://192.234.1.2/ di node lain. Jika berhasil hasilnya jadi : Welcome to K46 Dynamic Web App Server: Earendil (192.234.1.2) Endpoint: /app