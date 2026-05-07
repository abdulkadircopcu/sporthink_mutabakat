# -*- coding: utf-8 -*-
from .base_importer import BaseImporter
import pandas as pd
import os

class PazaramaImporter(BaseImporter):
    """
    Pazarama komisyon/kargo dosyasini iceri aktarir.
    Tek bir Excel dosyasinda 4 sayfa bulunur:
        - SatıcıFatura       → pazarama_fatura_ozet
        - SatıcıFaturaDetay  → pazarama_komisyon_detay
        - KargoFaturaDetay   → pazarama_kargo_detay
        - Tedarik ve Geciken → pazarama_ceza
    """

    SAYFA_TABLO_MAP = {
        "SatıcıFatura":       "pazarama_fatura_ozet",
        "SaticiFatura":       "pazarama_fatura_ozet",
        "SatıcıFaturaDetay":  "pazarama_komisyon_detay",
        "SaticiFaturaDetay":  "pazarama_komisyon_detay",
        "KargoFaturaDetay":   "pazarama_kargo_detay",
        "Tedarik ve Geciken": "pazarama_ceza",
        "Tedarik Ve Geciken": "pazarama_ceza",
    }

    # Excel → DB kolon eslesmesi: pazarama_fatura_ozet
    FATURA_OZET_KOLON_MAP = {
        "enterasyon_bedeli": "entegrasyon_bedeli",
    }

    # Excel → DB kolon eslesmesi: pazarama_komisyon_detay
    # Veritabani kolonlari:
    # id, fatura_no, fatura_tarihi, fatura_turu, bayi_kodu, satici_adi,
    # siparis_no, takip_no, siparis_durumu, siparis_tarihi, karsi_islem_id,
    # siparis_tutari, satici_komisyon_tutari, entegrasyon_bedeli,
    # etm_tutari, etm_komisyonu, olusturma_tarihi
    KOMISYON_DETAY_KOLON_MAP = {
        "siparis_numarasi":     "siparis_no",
        "enterasyon_bedeli":    "entegrasyon_bedeli",
        "entegrasyon_bedeli":   "entegrasyon_bedeli",
    }

    KOMISYON_DETAY_VALID_COLS = {
        "fatura_no", "fatura_tarihi", "fatura_turu", "bayi_kodu", "satici_adi",
        "siparis_no", "takip_no", "siparis_durumu", "siparis_tarihi",
        "karsi_islem_id", "siparis_tutari", "satici_komisyon_tutari",
        "entegrasyon_bedeli", "etm_tutari", "etm_komisyonu",
    }

    # Excel → DB kolon eslesmesi: pazarama_kargo_detay
    KARGO_DETAY_KOLON_MAP = {
        "fatura_no":        "fatura_no",
        "fatura_tarihi":    "fatura_tarihi",
        "fatura_turu":      "fatura_turu",
        "kargo_firmasi":    "kargo_firmasi",
        "bayi_kodu":        "bayi_kodu",
        "siparis_durumu":   "siparis_durumu",
        "donem":            "donem",
        "siparis_no":       "siparis_no",
        "takip_no":         "takip_no",
        "desi":             "desi",
        "satici_borcu":     "satici_borcu",
        "gonderi_numarasi": "gonderi_numarasi",
    }

    KARGO_DETAY_VALID_COLS = set(KARGO_DETAY_KOLON_MAP.values())


    # ----------------------------------------------------------
    # Ana import fonksiyonu — tek dosyadan 4 sayfayi okur
    # ----------------------------------------------------------

    def import_tumu(self, excel_path: str):
        if not os.path.exists(excel_path):
            raise FileNotFoundError(f"Dosya bulunamadi: '{excel_path}'")

        print(f"\n📂 Pazarama dosyasi okunuyor: {excel_path}")
        xl = pd.ExcelFile(excel_path)
        bulunan_sayfalar = xl.sheet_names
        print(f"   Sayfalar: {bulunan_sayfalar}")

        eslesmedi = []

        for sayfa in bulunan_sayfalar:
            tablo = self.SAYFA_TABLO_MAP.get(sayfa)
            if not tablo:
                tablo = self._sayfa_bul(sayfa)
            if not tablo:
                print(f"   ⚠️  '{sayfa}' sayfasi icin eslesme bulunamadi, atlandi.")
                eslesmedi.append(sayfa)
                continue

            print(f"\n   📄 '{sayfa}' → '{tablo}' tablosuna aktariliyor...")
            df = pd.read_excel(excel_path, sheet_name=sayfa)
            df = self._temizle(df, tablo)

            if df.empty:
                print(f"   ⚠️  '{sayfa}' sayfasi bos, atlandi.")
                continue

            self.save_to_db(df, tablo)

        if eslesmedi:
            print(f"\n   ❗ Eslesmeyen sayfalar: {eslesmedi}")

        print(f"\n✅ Pazarama import tamamlandi: {excel_path}\n")


    # ----------------------------------------------------------
    # Yardimci (private) fonksiyonlar
    # ----------------------------------------------------------

    def _import_sayfa(self, excel_path: str, sayfa_adi: str, tablo: str):
        print(f"📂 '{sayfa_adi}' sayfasi okunuyor: {excel_path}")
        df = pd.read_excel(excel_path, sheet_name=sayfa_adi)
        df = self._temizle(df, tablo)
        if df.empty:
            print(f"⚠️  Bos sayfa, atlandi.")
            return
        self.save_to_db(df, tablo)

    def _temizle(self, df, tablo: str):
        from .base_importer import clean_column_name
        import re

        df.columns = [clean_column_name(col) for col in df.columns]
        df = df.dropna(how='all').reset_index(drop=True)

        # Desi kolon adini normalize et
        df.columns = [
            "desi" if re.match(r"^(kg.?desi|desi.?kg|desi_+\w+|\w+_+desi)$", col)
            else col
            for col in df.columns
        ]

        # pazarama_fatura_ozet kolon eslestirme
        if tablo == "pazarama_fatura_ozet":
            df = df.rename(columns=self.FATURA_OZET_KOLON_MAP)

        # pazarama_komisyon_detay kolon eslestirme ve filtreleme
        if tablo == "pazarama_komisyon_detay":
            df = df.rename(columns=self.KOMISYON_DETAY_KOLON_MAP)
            valid_cols = [col for col in df.columns if col in self.KOMISYON_DETAY_VALID_COLS]
            df = df[valid_cols]

        # pazarama_kargo_detay kolon eslestirme ve filtreleme
        if tablo == "pazarama_kargo_detay":
            df = df.rename(columns=self.KARGO_DETAY_KOLON_MAP)
            valid_cols = [col for col in df.columns if col in self.KARGO_DETAY_VALID_COLS]
            df = df[valid_cols]

        return df

    def _sayfa_bul(self, sayfa_adi: str) -> str | None:
        from .base_importer import clean_column_name
        normalize = clean_column_name(sayfa_adi)
        for anahtar, tablo in self.SAYFA_TABLO_MAP.items():
            if clean_column_name(anahtar) == normalize:
                return tablo
        return None