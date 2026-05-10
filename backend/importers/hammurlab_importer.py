# -*- coding: utf-8 -*-
from .base_importer import BaseImporter
import pandas as pd

class HamurlabSiparisImporter(BaseImporter):
    """
    Hamurlab siparis listesini iceri aktarir.
    hamurlab_siparisler tablosuna yazar.

    Dosya: gelenSiparisListesi.xlsx
    Sayfa: selling_orders_details

    Siparis no ayristirma:
    '9632136875_7563212001' → takip_no: '9632136875', siparis_no: '7563212001'
    """

    # Excel kolon adi → DB kolon adi
    KOLON_MAP = {
        'takip_numarasi':           'takip_numarasi',
        'siparis_tipi':             'siparis_tipi',
        'magaza':                   'magaza',
        'urun_adi':                 'urun_adi',
        'urun_kodu':                'urun_kodu',
        'barkod':                   'barkod',
        'marka':                    'marka',
        'varyant':                  'varyant',
        'adet':                     'adet',
        'fiyat':                    'fiyat',
        'kdv_orani':                'kdv_orani',
        'kdvsiz_satis_fiyati':      'kdvsiz_satis_fiyati',
        'musteri':                  'musteri',
        'olusma_zamani':            'olusma_zamani',
        'toplama_kapanis_zamani':   'toplama_kapanis_zamani',
        'paketleme_tarihi':         'paketleme_tarihi',
        'kargo_gonderim_tarihi':    'kargo_gonderim_tarihi',
        'durum':                    'durum',
        'kargo_kampanya_kodu':      'kargo_kampanya_kodu',
        'erp_olusma_zamani':        'erp_olusma_zamani',
        'urun_tipi':                'urun_tipi',
        'renk':                     'renk',
        'po':                       'po',
        'kategori_grubu':           'kategori_grubu',
        'sku':                      'sku',
        'ean':                      'ean',
        'kaynak':                   'kaynak',
        'odeme_tipi':               'odeme_tipi',
        'set_barkodu':              'set_barkodu',
        'teslim_tarihi':            'teslim_tarihi',
        'desi':                     'desi',
        'siparis_desisi':           'siparis_desisi',
        'ilk_urun_adedi':           'ilk_urun_adedi',
        'iptal_urun_adedi':         'iptal_urun_adedi',
        'iade_urun_adedi':          'iade_urun_adedi',
        'komisyon':                 'komisyon',
        'toplanan_adet':            'toplanan_adet',
        'paketlenmemis_adet':       'paketlenmemis_adet',
        'gonderim_tipi':            'gonderim_tipi',
        'price_at_the_time_of_sale': 'satis_anindaki_fiyat',
        'toplam_fiyat':             'toplam_fiyat',
        'pazar_yeri_fiyati':        'pazar_yeri_fiyati',
        'entegrasyon_indirim_orani': 'entegrasyon_indirim_orani',
        'indirim_tutari':           'indirim_tutari',
        'kdvsiz_toplam_fiyati':     'kdvsiz_toplam_fiyat',
        'magaza_indirim_tutari':    'magaza_indirim_tutari',
        'external_id':              'external_id',
    }

    VALID_COLS = set(KOLON_MAP.values()) | {'takip_no', 'siparis_no'}

    def ayir_takip_siparis(self, deger: str):
        """
        Takip Numarasi alanini takip_no ve siparis_no olarak ayirir.
        Ayirici: _ (alt cizgi)
        """
        if not deger or str(deger).strip() in ('', 'nan', 'NaN'):
            return None, None
        deger = str(deger).strip()
        if '_' in deger:
            parcalar = deger.split('_')
            return parcalar[0], parcalar[1]
        return None, deger

    def import_siparisler(self, excel_path: str):
        """
        Hamurlab siparis listesini okur, hamurlab_siparisler tablosuna yazar.
        """
        print(f"📂 Hamurlab siparis dosyasi okunuyor: {excel_path}")

        df = pd.read_excel(excel_path, sheet_name="selling_orders_details", dtype=str)
        df = df.dropna(how='all').reset_index(drop=True)

        from .base_importer import clean_column_name
        df.columns = [clean_column_name(col) for col in df.columns]

        print(f"   {len(df)} satir bulundu.")

        # Takip no ve siparis no ayristir
        df[['takip_no', 'siparis_no']] = df['takip_numarasi'].apply(
            lambda x: pd.Series(self.ayir_takip_siparis(x))
        )

        # Kolon eslestirme
        df = df.rename(columns=self.KOLON_MAP)

        # Sadece gecerli kolonlari al
        valid_cols = [col for col in df.columns if col in self.VALID_COLS]
        df = df[valid_cols]

        self.save_to_db(df, 'hamurlab_siparisler')
        print(f"✅ Hamurlab siparis import tamamlandi.")

        
# -*- coding: utf-8 -*-
from .base_importer import BaseImporter
import pandas as pd

class HamurlabIptalIadeImporter(BaseImporter):
    """
    Hamurlab iptal ve iade listesini iceri aktarir.
    hamurlab_iptal_iade tablosuna yazar.

    Dosya: iptaliadeListesi.xlsx
    Sayfa: cancellation_return_report

    Siparis no ayristirma:
    '32153296257-1' → takip_no: '32153296257', siparis_no: '1'
    Not: Bu dosyada ayirici - (tire), diger dosyalarda _ (alt cizgi)
    """

    KOLON_MAP = {
        'siparis_tarihi':           'siparis_tarihi',
        'siparis_tipi':             'siparis_tipi',
        'kaynak':                   'kaynak',
        'magaza':                   'magaza',
        'takip_numarasi':           'takip_numarasi',
        'siparis_durumu':           'siparis_durumu',
        'urun_kodu':                'urun_kodu',
        'urun_adi':                 'urun_adi',
        'barkod':                   'barkod',
        'sku':                      'sku',
        'iade_iptal_adedi':         'iade_iptal_adedi',
        'satis_fiyati':             'satis_fiyati',
        'kaynak_depo':              'kaynak_depo',
        'full_parcali':             'tam_parcali',
        'iade_iptal_turu':          'iade_iptal_turu',
        'iade_iptal_tarihi':        'iade_iptal_tarihi',
        'neden':                    'neden',
        'kargo_kampanya_kodu':      'kargo_kampanya_kodu',
        'iade_iptal_orani':         'iade_iptal_orani',
        'odeme_tipi':               'odeme_tipi',
        'iade_iptal_satis_fiyati':  'iade_iptal_satis_fiyati',
        'iade_edilecek_toplam_tutar': 'iade_edilecek_toplam_tutar',
        'ret_nedeni':               'ret_nedeni',
        'ret_aciklamasi':           'ret_aciklamasi',
        'durum':                    'durum',
        'kargo_kabul_tarihi':       'kargo_kabul_tarihi',
        'teslim_tarihi':            'teslim_tarihi',
        'musteri':                  'musteri',
        'iade_kargo_kodu':          'iade_kargo_kodu',
        'tasiyici':                 'tasiyici',
        'kategori_grubu':           'kategori_grubu',
        'marka':                    'marka',
        'tedarikci_kodu':           'tedarikci_kodu',
        'e_ticaret_ana_grup':       'eticaret_ana_grup',
    }

    VALID_COLS = set(KOLON_MAP.values()) | {'takip_no', 'siparis_no'}

    def ayir_takip_siparis(self, deger: str):
        """
        Takip Numarasi alanini takip_no ve siparis_no olarak ayirir.
        Bu dosyada ayirici - (tire).
        Ornek: '32153296257-1' → takip_no: '32153296257', siparis_no: '1'
        """
        if not deger or str(deger).strip() in ('', 'nan', 'NaN'):
            return None, None
        deger = str(deger).strip()
        if '-' in deger:
            # Son - den ayir (bazi degerlerde birden fazla - olabilir)
            idx = deger.rfind('-')
            return deger[:idx], deger[idx+1:]
        return None, deger

    def import_iptal_iade(self, excel_path: str):
        """
        Hamurlab iptal/iade listesini okur, hamurlab_iptal_iade tablosuna yazar.
        """
        print(f"📂 Hamurlab iptal/iade dosyasi okunuyor: {excel_path}")

        df = pd.read_excel(excel_path, sheet_name="cancellation_return_report", dtype=str)
        df = df.dropna(how='all').reset_index(drop=True)

        from .base_importer import clean_column_name
        df.columns = [clean_column_name(col) for col in df.columns]

        print(f"   {len(df)} satir bulundu.")

        # Takip no ve siparis no ayristir
        df[['takip_no', 'siparis_no']] = df['takip_numarasi'].apply(
            lambda x: pd.Series(self.ayir_takip_siparis(x))
        )

        # Kolon eslestirme
        df = df.rename(columns=self.KOLON_MAP)

        # Sadece gecerli kolonlari al
        valid_cols = [col for col in df.columns if col in self.VALID_COLS]
        df = df[valid_cols]

        self.save_to_db(df, 'hamurlab_iptal_iade')
        print(f"✅ Hamurlab iptal/iade import tamamlandi.")