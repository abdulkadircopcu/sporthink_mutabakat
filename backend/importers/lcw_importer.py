from .base_importer import BaseImporter

class LcwImporter(BaseImporter):
    """
    LCW kargo faturalarini, komisyon faturalarini ve desi fiyatlarini
    ayri dosyalar olarak gonderir.
    """

    # Excel kolon adi → DB kolon adi (kargo faturasi)
    KARGO_FATURA_KOLON_MAP = {
        "siparis_numarasi":           "siparis_no",
        "islem_tarihi_teslim_tarihi": "teslim_tarihi",
        "fatura_numarasi":            "fatura_no",
    }

    # Geçerli lcw_komisyon_faturalari DB kolon adları
    KOMISYON_FATURA_VALID_COLS = {
        "islem_kayit_no", "satici", "cari_kod", "siparis_no", "takip_no", "paket_no",
        "barkod", "marka", "urun_kategori", "urun_adi", "islem_tipi", "siparis_tarihi",
        "islem_tarihi", "vade_gunu", "vade_tarihi", "hakedis_haftasi", "not_alani",
        "muhasebe_gunluk_no", "pesin_urun_tutari", "taksitli_urun_tutari", "lcw_taksit_farki",
        "lcwaikiki_sponsorlugu", "satici_sponsorlugu", "toplam_indirim", "indirim_aciklamasi",
        "satis_tutari", "komisyon_orani", "lcw_komisyon_hakedis", "lcw_toplam_hakedis",
        "satici_hakedis", "fatura_no", "fatura_tarihi", "yan_not", "mevzuat_pesin_tutar",
        "mevzuat_taksitli_tutar"
    }

    # Excel kolon adi → DB kolon adi (komisyon faturasi)
    KOMISYON_FATURA_KOLON_MAP = {
        # İşlem & Kayıt
        "islem_kayt_no":            "islem_kayit_no",
        "islem_kayit_no":           "islem_kayit_no",
        
        # Siparisler
        "siparis_numarasi":         "siparis_no",
        "siparis_no_":              "siparis_no",
        "siparis_no":               "siparis_no",
        
        # Takip & Paket
        "takip_no":                 "takip_no",
        "paket_no":                 "paket_no",
        "barkod":                   "barkod",
        
        # Kategori & Marka & Ürün
        "marka":                    "marka",
        "urun_kategori":            "urun_kategori",
        "urun_adi":                 "urun_adi",
        "islem_tipi":               "islem_tipi",
        
        # Tarihl
        "siparis_tarihi":           "siparis_tarihi",
        "islem_tarihi":             "islem_tarihi",
        "fatura_tarihi":            "fatura_tarihi",
        "vade_tarihi":              "vade_tarihi",
        "vade_gunu":                "vade_gunu",
        
        # Hakediş
        "hakedis_haftasi":          "hakedis_haftasi",
        
        # Faturalar
        "fatura_numarasi":          "fatura_no",
        "fatura_no":                "fatura_no",
        
        # Notlar
        "not":                      "not_alani",
        "not_alani":                "not_alani",
        "yan_not":                  "yan_not",
        "muhasebe_gunluk_no":       "muhasebe_gunluk_no",
        
        # Tutarlar
        "pesin_urun_tutari":        "pesin_urun_tutari",
        "taksitli_urun_tutari":     "taksitli_urun_tutari",
        "lcw_taksit_farki":         "lcw_taksit_farki",
        "lcwaikiki_sponsorlugu":    "lcwaikiki_sponsorlugu",
        "satici_sponsorlugu":       "satici_sponsorlugu",
        "toplam_indirim":           "toplam_indirim",
        "indirim_aciklamasi":       "indirim_aciklamasi",
        "satis_tutari":             "satis_tutari",
        "komisyon_orani":           "komisyon_orani",
        "lcw_komisyon_hakedis":     "lcw_komisyon_hakedis",
        "lcw_toplam_hakedis":       "lcw_toplam_hakedis",
        "satici_hakedis":           "satici_hakedis",
        "mevzuat_pesin_tutar":      "mevzuat_pesin_tutar",
        "mevzuat_taksitli_tutar":   "mevzuat_taksitli_tutar",
        
        # Cari & Satıcı
        "cari_kod":                 "cari_kod",
        "satici":                   "satici",
    }

    def import_kargo_faturasi(self, excel_path):
        """Kargo faturasi → lcw_kargo_faturalari"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KARGO_FATURA_KOLON_MAP)
        self.save_to_db(df, "lcw_kargo_faturalari")

    def import_komisyon_faturasi(self, excel_path):
        """Komisyon faturasi → lcw_komisyon_faturalari"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KOMISYON_FATURA_KOLON_MAP)
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.KOMISYON_FATURA_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "lcw_komisyon_faturalari")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → lcw_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "lcw_kargo_desi_fiyatlari")
