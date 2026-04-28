from .base_importer import BaseImporter

class N11Importer(BaseImporter):
    """
    N11 kargo ve komisyon faturalarını ayrı dosyalar olarak gönderir.
    """

    def import_kargo(self, excel_path):
        """Kargo listesi → n11_kargo"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "n11_kargo")

    def import_komisyon_faturasi(self, excel_path):
        """Komisyon faturası → n11_komisyon_faturalari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "n11_komisyon_faturalari")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → n11_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "n11_kargo_desi_fiyatlari")
