from .base_importer import BaseImporter

class TrendyolImporter(BaseImporter):
    """
    Trendyol, her fatura türünü ayrı Excel dosyası olarak gönderir.
    Her method farklı bir Excel tipini ilgili tabloya yükler.
    """

    def import_kargo_faturasi(self, excel_path):
        """Kargo faturası → trendyol_kargo_faturalari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_kargo_faturalari")

    def import_komisyon_faturasi(self, excel_path):
        """Komisyon faturası → trendyol_komisyon_faturalari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_komisyon_faturalari")

    def import_ceza_faturasi(self, excel_path):
        """Ceza faturası (kusurlu/yanlış/gecikme) → trendyol_ceza_faturalari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_ceza_faturalari")

    def import_islem_bedelleri(self, excel_path):
        """Platform/uluslararası işlem bedelleri → trendyol_islem_bedelleri"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_islem_bedelleri")

    def import_iptal_listesi(self, excel_path):
        """İptal listesi → trendyol_iptal_listesi"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_iptal_listesi")

    def import_yurtdisi_operasyon(self, excel_path):
        """Yurt dışı operasyon bedeli → trendyol_yurtdisi_operasyon"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_yurtdisi_operasyon")

    def import_kargo_desi_fiyatlari(self, excel_path):
        """Kargo desi fiyat listesi → trendyol_kargo_desi_fiyatlari"""
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "trendyol_kargo_desi_fiyatlari")
