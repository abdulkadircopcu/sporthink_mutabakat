# -*- coding: utf-8 -*-
import pandas as pd
from sqlalchemy import create_engine
import os

def clean_column_name(col):
    col = str(col)
    # Once Turkce buyuk harfleri donustur (Python .lower() I→i̇ yapar, bu DB ile uyusmaz)
    buyuk_kucuk = {
        'İ': 'i', 'I': 'i', 'Ğ': 'g', 'Ü': 'u', 'Ö': 'o', 'Ç': 'c', 'Ş': 's',
        'ğ': 'g', 'ı': 'i', 'ü': 'u', 'ö': 'o', 'ç': 'c', 'ş': 's',
        ' ': '_', '-': '_', '/': '_',
        # Ozel karakterleri kaldir (kolon adina girmemeli)
        "'": '', '"': '', '(': '', ')': '', '.': '', ',': '',
        '?': '', '!': '', '%': '', '#': '', '@': '', '&': '',
        ':': '', ';': '',
    }
    for tr, en in buyuk_kucuk.items():
        col = col.replace(tr, en)
    col = col.lower()  # kalan ASCII karakterleri kucult
    # Birden fazla alt cizgiyi tekle
    import re
    col = re.sub(r'_+', '_', col)
    return col.strip().strip('_')


class BaseImporter:
    def __init__(self, db_name="sporthink_mutabakat", host="localhost", user="root", password=""):
        self.db_name = db_name
        self.host = host
        self.user = user
        self.password = password
        
        # SQLAlchemy engine oluştur
        engine_str = f"mysql+mysqlconnector://{self.user}:{self.password}@{self.host}/{self.db_name}?charset=utf8mb4"
        self.engine = create_engine(engine_str)

    def prepare_df(self, excel_path):
        """Excel dosyasini okur, kolon isimlerini temizler ve bos satirlari atar."""
        if not os.path.exists(excel_path):
            raise FileNotFoundError(f"Hata: '{excel_path}' bulunamadi!")
            
        print(f"'{excel_path}' dosyasi okunuyor...")
        df = pd.read_excel(excel_path)
        
        df.columns = [clean_column_name(col) for col in df.columns]
        
        # Tum kolonlari bos olan satirlari at (Excel'deki bos/birlesmis satirlar)
        df = df.dropna(how='all').reset_index(drop=True)

        # Desi kolon adini normalize et:
        # kg_desi, desi_kg, desi___kg vb. → desi
        import re
        df.columns = [
            "desi" if re.match(r"^(kg.?desi|desi.?kg|desi_+\w+|\w+_+desi)$", col) or re.match(r"^desi[^a-z]", col)
            else col
            for col in df.columns
        ]
        
        return df

    def save_to_db(self, df, table_name):
        """DataFrame'i belirtilen tabloya kaydeder."""
        try:
            df.to_sql(name=table_name, con=self.engine, if_exists='append', index=False)
            print(f"[OK] Toplam {len(df)} satir '{self.db_name}.{table_name}' tablosuna eklendi.")
        except Exception as e:
            raise Exception(f"Veritabanina yuklenirken sorun: {e}")
