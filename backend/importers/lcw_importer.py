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

    def import_kargo_faturasi(self, excel_path):
        """Kargo faturasi → lcw_kargo_faturalari"""
        df = self.prepare_df(excel_path)
        df = df.rename(columns=self.KARGO_FATURA_KOLON_MAP)
        self.save_to_db(df, "lcw_kargo_faturalari")

    def import_komisyon_faturasi(self, excel_path):
        """Komisyon faturasi → lcw_komisyon_faturalari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "lcw_komisyon_faturalari")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → lcw_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "lcw_kargo_desi_fiyatlari")
