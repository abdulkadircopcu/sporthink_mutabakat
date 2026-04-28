from .base_importer import BaseImporter

class HepsiburadaImporter(BaseImporter):
    """
    Hepsiburada tüm hakedis verilerini tek bir dosyada gönderir.
    """

    # Excel'deki bitisik kolon adlari → DB kolon adlari
    KARGO_DESI_KOLON_MAP = {
        "araskargo":      "aras_kargo",
        "mngkargo":       "mng_kargo",
        "yurticikargo":   "yurtici_kargo",
        "suratkargo":     "surat_kargo",
        "pttkargo":       "ptt_kargo",
        "hepsijetxl":     "hepsijet_xl",
        "horozlojistik":  "horoz_lojistik",
        "cevalojistik":   "ceva_lojistik",
        "borusanlojistik":"borusan_lojistik",
    }

    # Excel'deki kolon adlari → DB kolon adlari (hakedis)
    HAKEDIS_KOLON_MAP = {
        "urun_no_sku":              "urun_no",
        "po_no":                    "po_no",
        "ongorulen_odeme_tarihi":   "ongorulen_odeme_tarihi",
    }

    def import_hakedis(self, excel_path):
        """Hakedis listesi → hepsiburada_hakedis"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.HAKEDIS_KOLON_MAP)
        self.save_to_db(df, "hepsiburada_hakedis")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → hepsiburada_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        # Excel'deki bitisik isimler → DB isimleri
        df = df.rename(columns=self.KARGO_DESI_KOLON_MAP)
        self.save_to_db(df, "hepsiburada_kargo_desi_fiyatlari")
