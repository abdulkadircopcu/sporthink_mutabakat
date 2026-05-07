from flask import Blueprint, request, jsonify
from pipeline import tam_pipeline_calistir

pipeline_bp = Blueprint("pipeline", __name__)


@pipeline_bp.route("/pipeline/calistir", methods=["POST"])
def pipeline_calistir():
    """
    Pazaryeri tablolarindaki verileri siparisler ve
    karlilik_ozeti tablolarina aktar.

    Body (opsiyonel):
        { "pazaryeri": "Trendyol" }
        {} → tum pazaryerler
    """
    try:
        data      = request.get_json(silent=True) or {}
        pazaryeri = data.get("pazaryeri")  # None → tum pazaryerler

        sonuc = tam_pipeline_calistir(pazaryeri)
        return jsonify({
            "basarili": True,
            "pazaryeri": pazaryeri or "Tumu",
            "sonuc": {
                "siparisler_sync": {
                    pz: {"upsert": v["upsert"], "hata": bool(v["hata"])}
                    for pz, v in sonuc["siparisler_sync"].items()
                },
                "karlilik_ozeti": sonuc["karlilik_ozeti"],
            }
        })

    except Exception as e:
        return jsonify({"basarili": False, "hata": str(e)}), 500


@pipeline_bp.route("/pipeline/durum", methods=["GET"])
def pipeline_durum():
    """karlilik_ozeti ve siparisler tablolarindaki kayit sayilarini döner."""
    from karlilik_hesaplama import get_db_connection

    conn   = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT COUNT(*) FROM siparisler")
        siparis_sayisi = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM karlilik_ozeti")
        ozet_sayisi = cursor.fetchone()[0]

        cursor.execute("""
            SELECT pazaryeri, COUNT(*) as n
            FROM siparisler
            GROUP BY pazaryeri
            ORDER BY n DESC
        """)
        pazaryeri_dagilimi = {row[0]: row[1] for row in cursor.fetchall()}

        return jsonify({
            "siparisler":          siparis_sayisi,
            "karlilik_ozeti":      ozet_sayisi,
            "pazaryeri_dagilimi":  pazaryeri_dagilimi,
        })
    finally:
        cursor.close()
        conn.close()
