from .base_importer import BaseImporter

class AmazonImporter(BaseImporter):
    def import_islemler(self, excel_path):
        df = self.prepare_df(excel_path)
        self.save_to_db(df, "amazon_islemler")
