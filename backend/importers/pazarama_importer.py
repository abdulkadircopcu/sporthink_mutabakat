from .base_importer import BaseImporter

class PazaramaImporter(BaseImporter):
    """
    Pazarama ceza, fatura özeti, kargo detay ve komisyon detaylarını
    ayrı dosyalar olarak gönderir.
    """

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
        self.save_to_db(df, "pazarama_kargo_detay")

    def import_komisyon_detay(self, excel_path):
        """Komisyon detay → pazarama_komisyon_detay"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "pazarama_komisyon_detay")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → pazarama_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "pazarama_kargo_desi_fiyatlari")
