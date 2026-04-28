from .base_importer import BaseImporter

class N11Importer(BaseImporter):
    """
    N11 kargo ve komisyon faturalarını ayrı dosyalar olarak gönderir.
    """

    # Excel kolon adi → DB kolon adi (kargo)
    KARGO_KOLON_MAP = {
        "siparis_kodu":         "siparis_kodu",
        "takip_no":             "takip_no",
        "kampanya_numarasi":    "kampanya_numarasi",
        "musteri":              "musteri",
        "islem_tarihi":         "islem_tarihi",
        "islem_turu":           "islem_turu",
        "kargo_sirketi":        "kargo_sirketi",
        "tl_desi_veya_kg":      "tl_desi_kg",  # Excel: "tl_desi_veya_kg" → DB: "tl_desi_kg"
        "tl_desi_kg":           "tl_desi_kg",
    }

    # Geçerli n11_kargo DB kolon adları
    KARGO_VALID_COLS = {
        "siparis_kodu", "takip_no", "kampanya_numarasi", "musteri",
        "islem_tarihi", "islem_turu", "kargo_sirketi", "tl_desi_kg"
    }

    # Excel kolon adi → DB kolon adi (komisyon faturasi)
    KOMISYON_FATURA_KOLON_MAP = {
        "siparis_numarasi":                 "siparis_no",
        "siparis_no":                       "siparis_no",
        "takip_no":                         "takip_no",
        "fatura_turu":                      "fatura_turu",
        "fatura_tarihi":                    "fatura_tarihi",
        "satici_id":                        "satici_id",
        "magaza_adi":                       "magaza_adi",
        "siparis_kalem_id":                 "siparis_kalem_id",
        "islem_tipi_tanimi":                "islem_tipi_tanimi",
        "siparis_tamamlanma_tarihi":        "siparis_tamamlanma_tarihi",
        "siparis_tutari":                   "siparis_tutari",
        "komisyon_orani":                   "komisyon_orani",
        "komisyon_bedeli":                  "komisyon_bedeli",
        "pazarlama_hizmet_bedeli":          "pazarlama_hizmet_bedeli",
        "pazaryeri_hizmet_bedeli":          "pazaryeri_hizmet_bedeli",
        "vade_farkli_yansitmasi_bagli_ceza_bedeli":  "vade_farki_yansitmasi",
        "vade_farki_yansitmasi":            "vade_farki_yansitmasi",
        "sozlesme_ceza_bedeli":             "sozlesme_ceza_bedeli",
        "reklam_bedeli":                    "reklam_bedeli",
        "k_fatura_numarasi":                "k_fatura_numarasi",
        "satici_hakedis_tutari":            "satici_hakedis_tutari",
        "hakedis_transfer_tarihi":          "hakedis_transfer_tarihi",
    }

    # Geçerli n11_komisyon_faturalari DB kolon adları
    KOMISYON_FATURA_VALID_COLS = {
        "fatura_turu", "fatura_tarihi", "satici_id", "magaza_adi", "siparis_no", "takip_no",
        "siparis_kalem_id", "islem_tipi_tanimi", "siparis_tamamlanma_tarihi", "siparis_tutari",
        "komisyon_orani", "komisyon_bedeli", "pazarlama_hizmet_bedeli", "pazaryeri_hizmet_bedeli",
        "vade_farki_yansitmasi", "sozlesme_ceza_bedeli", "reklam_bedeli", "k_fatura_numarasi",
        "satici_hakedis_tutari", "hakedis_transfer_tarihi"
    }


    def import_kargo(self, excel_path):
        """Kargo listesi → n11_kargo"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KARGO_KOLON_MAP)
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.KARGO_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "n11_kargo")

    def import_komisyon_faturasi(self, excel_path):
        """Komisyon faturası → n11_komisyon_faturalari"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KOMISYON_FATURA_KOLON_MAP)
        
        # Sadece geçerli DB kolonlarını tut
        valid_cols = [col for col in df.columns if col in self.KOMISYON_FATURA_VALID_COLS]
        df = df[valid_cols]
        
        self.save_to_db(df, "n11_komisyon_faturalari")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → n11_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "n11_kargo_desi_fiyatlari")
