from .base_importer import BaseImporter

class PazaramaImporter(BaseImporter):
    """
    Pazarama ceza, fatura özeti, kargo detay ve komisyon detaylarını
    ayrı dosyalar olarak gönderir.
    """

    # Geçerli pazarama_kargo_detay DB kolon adları
    KARGO_DETAY_VALID_COLS = {
        "fatura_no", "fatura_tarihi", "fatura_turu", "kargo_firmasi", "bayi_kodu",
        "siparis_durumu", "donem", "siparis_no", "takip_no", "desi", "satici_borcu",
        "gonderi_numarasi"
    }

    # Excel kolon adi → DB kolon adi (kargo detay)
    KARGO_DETAY_KOLON_MAP = {
        "fatura_no":            "fatura_no",
        "fatura_tarihi":        "fatura_tarihi",
        "fatura_turu":          "fatura_turu",
        "kargo_firmasi":        "kargo_firmasi",
        "bayi_kodu":            "bayi_kodu",
        "siparis_durumu":       "siparis_durumu",
        "donem":                "donem",
        "siparis_no":           "siparis_no",
        "takip_no":             "takip_no",
        "desi":                 "desi",
        "satici_borcu":         "satici_borcu",
        "gonderi_numarasi":     "gonderi_numarasi",
    }

    def import_ceza(self, excel_path):
        """Ceza listesi → pazarama_ceza"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "pazarama_ceza")

    def import_fatura_ozet(self, excel_path):
        """Fatura özeti → pazarama_fatura_ozet"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "pazarama_fatura_ozet")

    def import_kargo_detay(self, excel_path):
        """Kargo detay → pazarama_kargo_detay"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KARGO_DETAY_KOLON_MAP)
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.KARGO_DETAY_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "pazarama_kargo_detay")

    def import_komisyon_detay(self, excel_path):
        """Komisyon detay → pazarama_komisyon_detay"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "pazarama_komisyon_detay")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → pazarama_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "pazarama_kargo_desi_fiyatlari")
