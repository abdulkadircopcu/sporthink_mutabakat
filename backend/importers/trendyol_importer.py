from .base_importer import BaseImporter

class TrendyolImporter(BaseImporter):
    """
    Trendyol, her fatura türünü ayrı Excel dosyası olarak gönderir.
    Her method farklı bir Excel tipini ilgili tabloya yükler.
    """

    # Geçerli trendyol_kargo_faturalari DB kolon adları
    KARGO_FATURA_VALID_COLS = {
        "fatura_no", "fatura_turu", "fatura_tarihi", "satici_id", "gonderi_ucreti",
        "desi", "satici_ismi", "siparis_no", "takip_no", "gonderi_iade", "gonderi_iade_kodu",
        "kargo_firmasi", "siparis_tarihi", "sevk_tarihi", "siparis_tutari", "min_kampanya_baremi",
        "urun_adedi", "butik_id", "aciklama"
    }

    # Excel kolon adi → DB kolon adi (kargo faturasi)
    KARGO_FATURA_KOLON_MAP = {
        "fatura_no":                    "fatura_no",
        "fatura_turu":                  "fatura_turu",
        "fatura_tarihi":                "fatura_tarihi",
        "satici_id":                    "satici_id",
        "gonderi_ucreti_kdv_dahil":     "gonderi_ucreti",  # Excel: gonderi_ucreti_kdv_dahil → DB: gonderi_ucreti
        "gonderi_ucreti":               "gonderi_ucreti",
        "desi":                         "desi",
        "satici_ismi":                  "satici_ismi",
        "siparis_no":                   "siparis_no",
        "takip_no":                     "takip_no",
        "gonderi_iade":                 "gonderi_iade",
        "gonderi_iade_kodu":            "gonderi_iade_kodu",
        "kargo_firmasi":                "kargo_firmasi",
        "siparis_tarihi":               "siparis_tarihi",
        "sevk_tarihi":                  "sevk_tarihi",
        "siparis_tutari":               "siparis_tutari",
        "min_kampanya_baremi":          "min_kampanya_baremi",
        "urun_adedi":                   "urun_adedi",
        "butik_id":                     "butik_id",
        "aciklama":                     "aciklama",
    }

    # Geçerli trendyol_komisyon_faturalari DB kolon adları
    KOMISYON_FATURA_VALID_COLS = {
        "fatura_no", "fatura_turu", "fatura_tarihi", "satici_id", "kayit_no", "islem_tipi",
        "siparis_no", "takip_no", "siparis_tarihi", "ulke", "islem_tarihi", "satici",
        "satici_cari_adi", "urun_adi", "barkod", "komisyon_orani", "trendyol_hakedis",
        "satici_hakedis", "vade_suresi", "teslim_tarihi", "vade_tarihi", "toplam_tutar",
        "musteri_ad", "musteri_soyad", "magaza_no", "magaza_adi", "magaza_adresi"
    }

    # Excel kolon adi → DB kolon adi (komisyon faturasi)
    KOMISYON_FATURA_KOLON_MAP = {
        "fatura_no":                "fatura_no",
        "fatura_turu":              "fatura_turu",
        "fatura_tarihi":            "fatura_tarihi",
        "satici_id":                "satici_id",
        "kayit_no":                 "kayit_no",
        "islem_tipi":               "islem_tipi",
        "siparis_no":               "siparis_no",
        "siparis_numarasi":         "siparis_no",
        "takip_no":                 "takip_no",
        "siparis_tarihi":           "siparis_tarihi",
        "ulke":                     "ulke",
        "islem_tarihi":             "islem_tarihi",
        "satici":                   "satici",
        "satici_cari_adi":          "satici_cari_adi",
        "urun_adi":                 "urun_adi",
        "barkod":                   "barkod",
        "komisyon_orani":           "komisyon_orani",
        "trendyol_hakedis":         "trendyol_hakedis",
        "satici_hakedis":           "satici_hakedis",
        "vade_suresi":              "vade_suresi",
        "teslim_tarihi":            "teslim_tarihi",
        "vade_tarihi":              "vade_tarihi",
        "toplam_tutar":             "toplam_tutar",
        "musteri_ad":               "musteri_ad",
        "musteri_soyad":            "musteri_soyad",
        "magaza_nosu":              "magaza_no",  # Excel: magaza_nosu → DB: magaza_no
        "magaza_no":                "magaza_no",
        "magaza_adi":               "magaza_adi",
        "magaza_adresi":            "magaza_adresi",
    }


    # Geçerli trendyol_islem_bedelleri DB kolon adları
    ISLEM_BEDELLERI_VALID_COLS = {
        "fatura_no", "fatura_turu", "fatura_tarihi", "satici_id", "ek_ucret", "satici_ismi",
        "siparis_no", "takip_no", "gonderi_iade", "gonderi_iade_kodu", "kargo_firmasi",
        "siparis_tarihi", "sevk_tarihi", "siparis_tutari", "islem_tipi", "vade_tarihi",
        "affiliate", "aciklama"
    }

    # Excel kolon adi → DB kolon adi (islem bedelleri)
    ISLEM_BEDELLERI_KOLON_MAP = {
        "fatura_no":            "fatura_no",
        "fatura_turu":          "fatura_turu",
        "fatura_tarihi":        "fatura_tarihi",
        "satici_id":            "satici_id",
        "ek_ucret":             "ek_ucret",
        "satici_ismi":          "satici_ismi",
        "siparis_no":           "siparis_no",
        "siparis_numarasi":     "siparis_no",
        "takip_no":             "takip_no",
        "gonderi_iade":         "gonderi_iade",
        "gonderi_iade_kodu":    "gonderi_iade_kodu",
        "kargo_firmasi":        "kargo_firmasi",
        "siparis_tarihi":       "siparis_tarihi",
        "sevk_tarihi":          "sevk_tarihi",
        "siparis_tutari":       "siparis_tutari",
        "islem_tipi":           "islem_tipi",
        "vade_tarihi":          "vade_tarihi",
        "affiliate":            "affiliate",
        "aciklama":             "aciklama",
    }

    # Geçerli trendyol_ceza_faturalari DB kolon adları
    CEZA_FATURA_VALID_COLS = {
        "fatura_no", "fatura_turu", "fatura_tarihi", "satici_id", "satici_ismi", "siparis_no",
        "takip_no", "iade_kodu", "urun_adedi", "urun_tutari", "kesilen_bedel", "gonderi_kodu",
        "siparis_tarihi", "kargo_cikis_tarihi", "termin_geciken_urun_adedi", "geciken_urun_tutari",
        "not_alani"
    }

    # Excel kolon adi → DB kolon adi (ceza faturasi)
    CEZA_FATURA_KOLON_MAP = {
        "fatura_no":                    "fatura_no",
        "fatura_turu":                  "fatura_turu",
        "fatura_tarihi":                "fatura_tarihi",
        "satici_id":                    "satici_id",
        "satici_ismi":                  "satici_ismi",
        "siparis_no":                   "siparis_no",
        "siparis_numarasi":             "siparis_no",
        "takip_no":                     "takip_no",
        "iade_kodu":                    "iade_kodu",
        "urun_adedi":                   "urun_adedi",
        "urun_tutari":                  "urun_tutari",
        "kesilen_bedel":                "kesilen_bedel",
        "gonderi_kodu":                 "gonderi_kodu",
        "siparis_tarihi":               "siparis_tarihi",
        "kargo_cikis_tarihi":           "kargo_cikis_tarihi",
        "termin_geciken_urun_adedi":    "termin_geciken_urun_adedi",
        "geciken_urun_tutari":          "geciken_urun_tutari",
        "not_alani":                    "not_alani",
    }


    # Excel kolon adi → DB kolon adi (iptal listesi)
    IPTAL_LISTESI_KOLON_MAP = {
        "barkod":               "barkod",
        "paket_no":             "paket_no",
        "siparis_tarihi":       "siparis_tarihi",
        "iptal_tarihi":         "iptal_tarihi",
        "kargo_kodu":           "kargo_kodu",
        "siparis_numarasi":     "siparis_no",  # Excel: siparis_numarasi → DB: siparis_no
        "siparis_no":           "siparis_no",
        "takip_no":             "takip_no",
        "alici":                "alici",
        "urun_adi":             "urun_adi",
        "marka":                "marka",
        "stok_kodu":            "stok_kodu",
        "adet":                 "adet",
        "birim_fiyati":         "birim_fiyati",
        "iptal_tipi":           "iptal_tipi",
        "iptal_nedeni":         "iptal_nedeni",
    }


    def import_kargo_faturasi(self, excel_path):
        """Kargo faturası → trendyol_kargo_faturalari"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KARGO_FATURA_KOLON_MAP)
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.KARGO_FATURA_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "trendyol_kargo_faturalari")

    def import_komisyon_faturasi(self, excel_path):
        """Komisyon faturası → trendyol_komisyon_faturalari"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KOMISYON_FATURA_KOLON_MAP)
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.KOMISYON_FATURA_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "trendyol_komisyon_faturalari")

    def import_ceza_faturasi(self, excel_path, fatura_turu=None):
        """Ceza faturası (kusurlu/yanlış/gecikme) → trendyol_ceza_faturalari"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.CEZA_FATURA_KOLON_MAP)
        
        # Eğer fatura_turu parametresi gelmişse, kullan
        if fatura_turu:
            df['fatura_turu'] = fatura_turu
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.CEZA_FATURA_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "trendyol_ceza_faturalari")

    def import_islem_bedelleri(self, excel_path, fatura_turu=None):
        """Platform/uluslararası işlem bedelleri → trendyol_islem_bedelleri"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.ISLEM_BEDELLERI_KOLON_MAP)
        
        # Eğer fatura_turu parametresi gelmişse, kullan
        if fatura_turu:
            df['fatura_turu'] = fatura_turu
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.ISLEM_BEDELLERI_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "trendyol_islem_bedelleri")

    def import_iptal_listesi(self, excel_path):
        """İptal listesi → trendyol_iptal_listesi"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.IPTAL_LISTESI_KOLON_MAP)
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.IPTAL_LISTESI_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "trendyol_iptal_listesi")

    def import_yurtdisi_operasyon(self, excel_path):
        """Yurt dışı operasyon bedeli → trendyol_yurtdisi_operasyon"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_yurtdisi_operasyon")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → trendyol_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_kargo_desi_fiyatlari")
