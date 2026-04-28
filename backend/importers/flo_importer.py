from .base_importer import BaseImporter

class FloImporter(BaseImporter):
    """
    Flo fatura detaylarını ve kargo desi fiyatlarını ayrı dosyalar olarak gönderir.
    """

    def import_fatura_detay(self, excel_path):
        """Fatura detay (komisyon/ceza vb.) → flo_fatura_detay"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "flo_fatura_detay")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → flo_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "flo_kargo_desi_fiyatlari")
