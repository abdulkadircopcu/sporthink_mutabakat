# -*- coding: utf-8 -*-
from .base_importer import BaseImporter, clean_column_name
import pandas as pd


class HititSatisImporter(BaseImporter):
    """
    Hitit ERP satis dosyasini iceri aktarir.
    hitit_satislar tablosuna yazar.

    Dosya: barkodluSatisGuncelExcel.xlsx
    Sayfa: Grid

    Siparis no ayristirma:
    '3652674846_8969870214' → takip_no: '3652674846', siparis_no: '8969870214'
    """

    def ayir_takip_siparis(self, deger: str):
        """
        Belge Takip No alanini takip_no ve siparis_no olarak ayirir.
        Ayirici: _ (alt cizgi)
        """
        if not deger or str(deger).strip() in ('', 'nan', 'NaN'):
            return None, None
        deger = str(deger).strip()
        if '_' in deger:
            parcalar = deger.split('_')
            return parcalar[0], parcalar[1]
        return None, deger

    def import_satislar(self, excel_path: str):
        """
        Hitit satis dosyasini okur, hitit_satislar tablosuna yazar.
        Iade tutarlari pozitif olarak kaydedilir.
        """
        print(f"📂 Hitit satis dosyasi okunuyor: {excel_path}")

        df = pd.read_excel(excel_path, sheet_name="Grid", dtype=str)
        df = df.dropna(how='all').reset_index(drop=True)
        df.columns = [clean_column_name(col) for col in df.columns]

        print(f"   {len(df)} satir bulundu.")

        kayitlar = []
        for _, satir in df.iterrows():
            belge_takip_no = satir.get('belge_takip_no', '')
            takip_no, siparis_no = self.ayir_takip_siparis(belge_takip_no)

            kayit = {
                'satis_yeri_kodu':       satir.get('satis_yeri_kodu'),
                'satis_yeri_adi':        satir.get('satis_yeri_adi'),
                'belge_takip_no':        belge_takip_no,
                'takip_no':              takip_no,
                'siparis_no':            siparis_no,
                'zaman':                 satir.get('zaman'),
                'fatura_no':             satir.get('fatura_no'),
                'ozel_kod_1':            satir.get('ozel_kod_1'),
                'ozel_kod_2':            satir.get('ozel_kod_2'),
                'son_guncelleyen':       satir.get('son_guncelleyen_kullanici'),
                'barkod':                satir.get('satilan_urun_barkodu'),
                'urun_tutari_kdvsiz':    satir.get('satilan_urun_tutari_kdvsiz'),
                'urun_kdv_tutari':       satir.get('satilan_urun_kdv_tutari'),
                'urun_tutari_kdvli':     satir.get('satilan_urun_tutari_kdvli'),
                'urun_adedi':            satir.get('satilan_alinan_urun_adedi'),
                'satis_fatura_tarihi':   satir.get('satis_fatura_tarihi'),
                'stok_kodu':             satir.get('stok_kodu'),
                'marka':                 satir.get('marka'),
                'musteri_kodu':          satir.get('musteri_kodu'),
                'musteri_adi_soyadi':    satir.get('musteri_adi_soyadi'),
                'satis_sistem_numarasi': satir.get('satis_sistem_numarasi'),
                'eticaret_web_adresi':   satir.get('e_ticaret_web_adresi'),
            }
            kayitlar.append(kayit)

        df_kayit = pd.DataFrame(kayitlar)
        self.save_to_db(df_kayit, 'hitit_satislar')
        print(f"✅ Hitit satis import tamamlandi.")


class HititIadeImporter(BaseImporter):
    """
    Hitit ERP iade dosyasini iceri aktarir.
    hitit_iadeler tablosuna yazar.

    Dosya: barkodluIadeGuncel.xlsx
    Sayfa: Grid

    Onemli: Iade tutarlari Excel'de negatif geliyor (-1986.36)
    Import sirasinda pozitife cevriliyor.

    Siparis no ayristirma:
    '74632165587_74563213827' → takip_no: '74632165587', siparis_no: '74563213827'
    """

    def ayir_takip_siparis(self, deger: str):
        """
        Siparis No alanini takip_no ve siparis_no olarak ayirir.
        Ayirici: _ (alt cizgi)
        """
        if not deger or str(deger).strip() in ('', 'nan', 'NaN'):
            return None, None
        deger = str(deger).strip()
        if '_' in deger:
            parcalar = deger.split('_')
            return parcalar[0], parcalar[1]
        return None, deger

    def pozitife_cevir(self, deger):
        """Negatif gelen iade tutarlarini pozitife ceviriyor."""
        try:
            return abs(float(str(deger).strip()))
        except:
            return None

    def import_iadeler(self, excel_path: str):
        """
        Hitit iade dosyasini okur, hitit_iadeler tablosuna yazar.
        """
        print(f"📂 Hitit iade dosyasi okunuyor: {excel_path}")

        df = pd.read_excel(excel_path, sheet_name="Grid", dtype=str)
        df = df.dropna(how='all').reset_index(drop=True)
        df.columns = [clean_column_name(col) for col in df.columns]

        print(f"   {len(df)} satir bulundu.")

        kayitlar = []
        for _, satir in df.iterrows():
            siparis_no_ham = satir.get('siparis_no', '')
            takip_no, siparis_no = self.ayir_takip_siparis(siparis_no_ham)

            kayit = {
                'satis_yeri_kodu':       satir.get('iade_alinan_fatura_satis_yeri_kodu'),
                'satis_yeri_adi':        satir.get('iade_alinan_fatura_satis_yeri_adi'),
                'zaman':                 satir.get('zaman'),
                'gider_pusulasi_tarihi': satir.get('gider_pusulasi_tarihi'),
                'ozel_kod_1':            satir.get('ozel_kod_1'),
                'ozel_kod_2':            satir.get('ozel_kod_2'),
                'son_guncelleyen':       satir.get('son_guncelleyen_kullanici'),
                'iade_fatura_sistem_no': satir.get('iade_alinan_fatura_sistem_no'),
                'iade_fatura_no':        satir.get('iade_alinan_fatura_no'),
                'siparis_no':            siparis_no,
                'takip_no':              takip_no,
                'barkod':                satir.get('iade_alinan_urun_barkodu'),
                # Negatif gelen tutarlari pozitife cevir
                'urun_tutari_kdvsiz':    self.pozitife_cevir(satir.get('iade_alinan_urun_tutari_kdvsiz')),
                'urun_kdv_tutari':       self.pozitife_cevir(satir.get('iade_alinan_urun_kdv_tutari')),
                'urun_tutari_kdvli':     self.pozitife_cevir(satir.get('iade_alinan_urun_tutari_kdvli')),
                'urun_adedi':            self.pozitife_cevir(satir.get('iade_alinan_urun_adedi')),
                'iade_fatura_tarihi':    satir.get('iade_alinan_fatura_tarihi'),
                'stok_kodu':             satir.get('stok_kodu'),
                'marka':                 satir.get('marka'),
                'musteri_kodu':          satir.get('musteri_kodu'),
                'musteri_adi_soyadi':    satir.get('musteri_adi_soyadi'),
                'iade_sistem_numarasi':  satir.get('iade_sistem_numarasi'),
                'eticaret_web_adresi':   satir.get('e_ticaret_web_adresi'),
            }
            kayitlar.append(kayit)

        df_kayit = pd.DataFrame(kayitlar)
        self.save_to_db(df_kayit, 'hitit_iadeler')
        print(f"✅ Hitit iade import tamamlandi.")