import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from importers.trendyol_importer import TrendyolImporter
from importers.amazon_importer import AmazonImporter
from importers.hepsiburada_importer import HepsiburadaImporter
from importers.n11_importer import N11Importer
from importers.pazarama_importer import PazaramaImporter
from importers.flo_importer import FloImporter
from importers.lcw_importer import LcwImporter


def dosya_sor(aciklama):
    """Kullanıcıdan Excel dosyası yolu alır ve varlığını kontrol eder."""
    dosya = input(f"{aciklama} [Excel yolu]: ").strip()
    if not os.path.exists(dosya):
        print(f"  [HATA] Dosya bulunamadi: '{dosya}'")
        return None
    return dosya


def ana_menu():
    print("\n" + "="*55)
    print("     E-TICARET VERI AKTARIM SISTEMI")
    print("="*55)
    print("  1. Trendyol")
    print("  2. Amazon")
    print("  3. Hepsiburada")
    print("  4. N11")
    print("  5. Pazarama")
    print("  6. Flo")
    print("  7. LCW")
    print("  0. Çıkış")
    print("-"*55)
    return input("  Pazaryeri seçin (0-7): ").strip()


# -------------------------------------------------------
# Trendyol
# -------------------------------------------------------
def trendyol_menusu():
    print("\n--- Trendyol ---")
    print("  1. Kargo Faturası           → trendyol_kargo_faturalari")
    print("  2. Komisyon Faturası        → trendyol_komisyon_faturalari")
    print("  3. Ceza Faturası            → trendyol_ceza_faturalari")
    print("  4. İşlem Bedelleri          → trendyol_islem_bedelleri")
    print("  5. İptal Listesi            → trendyol_iptal_listesi")
    print("  6. Yurt Dışı Operasyon      → trendyol_yurtdisi_operasyon")
    print("  7. Kargo Desi Fiyatları     → trendyol_kargo_desi_fiyatlari")
    secim = input("  Seçim (1-7): ").strip()

    metodlar = {
        "1": ("Kargo Faturası", TrendyolImporter().import_kargo_faturasi),
        "2": ("Komisyon Faturası", TrendyolImporter().import_komisyon_faturasi),
        "3": ("Ceza Faturası", TrendyolImporter().import_ceza_faturasi),
        "4": ("İşlem Bedelleri", TrendyolImporter().import_islem_bedelleri),
        "5": ("İptal Listesi", TrendyolImporter().import_iptal_listesi),
        "6": ("Yurt Dışı Operasyon", TrendyolImporter().import_yurtdisi_operasyon),
        "7": ("Kargo Desi Fiyatları", TrendyolImporter().import_kargo_desi_fiyatlari),
    }

    if secim in metodlar:
        aciklama, metod = metodlar[secim]
        dosya = dosya_sor(aciklama)
        if dosya:
            metod(dosya)
    else:
        print("  [HATA] Gecersiz secim.")


# -------------------------------------------------------
# Amazon
# -------------------------------------------------------
def amazon_menusu():
    print("\n--- Amazon ---")
    print("  1. İşlem Listesi            → amazon_islemler")
    secim = input("  Seçim (1): ").strip()

    if secim == "1":
        dosya = dosya_sor("Amazon İşlem Listesi")
        if dosya:
            AmazonImporter().import_islemler(dosya)
    else:
        print("  [HATA] Gecersiz secim.")


# -------------------------------------------------------
# Hepsiburada
# -------------------------------------------------------
def hepsiburada_menusu():
    print("\n--- Hepsiburada ---")
    print("  1. Hakediş Listesi          → hepsiburada_hakedis")
    print("  2. Kargo Desi Fiyatları     → hepsiburada_kargo_desi_fiyatlari")
    secim = input("  Seçim (1-2): ").strip()

    metodlar = {
        "1": ("Hakediş Listesi", HepsiburadaImporter().import_hakedis),
        "2": ("Kargo Desi Fiyatları", HepsiburadaImporter().import_kargo_desi_fiyatlari),
    }

    if secim in metodlar:
        aciklama, metod = metodlar[secim]
        dosya = dosya_sor(aciklama)
        if dosya:
            metod(dosya)
    else:
        print("  [HATA] Gecersiz secim.")


# -------------------------------------------------------
# N11
# -------------------------------------------------------
def n11_menusu():
    print("\n--- N11 ---")
    print("  1. Kargo Listesi            → n11_kargo")
    print("  2. Komisyon Faturası        → n11_komisyon_faturalari")
    print("  3. Kargo Desi Fiyatları     → n11_kargo_desi_fiyatlari")
    secim = input("  Seçim (1-3): ").strip()

    metodlar = {
        "1": ("Kargo Listesi", N11Importer().import_kargo),
        "2": ("Komisyon Faturası", N11Importer().import_komisyon_faturasi),
        "3": ("Kargo Desi Fiyatları", N11Importer().import_kargo_desi_fiyatlari),
    }

    if secim in metodlar:
        aciklama, metod = metodlar[secim]
        dosya = dosya_sor(aciklama)
        if dosya:
            metod(dosya)
    else:
        print("  [HATA] Gecersiz secim.")


# -------------------------------------------------------
# Pazarama
# -------------------------------------------------------
def pazarama_menusu():
    print("\n--- Pazarama ---")
    print("  1. Ceza Listesi             → pazarama_ceza")
    print("  2. Fatura Özeti             → pazarama_fatura_ozet")
    print("  3. Kargo Detay              → pazarama_kargo_detay")
    print("  4. Komisyon Detay           → pazarama_komisyon_detay")
    print("  5. Kargo Desi Fiyatları     → pazarama_kargo_desi_fiyatlari")
    secim = input("  Seçim (1-5): ").strip()

    metodlar = {
        "1": ("Ceza Listesi", PazaramaImporter().import_ceza),
        "2": ("Fatura Özeti", PazaramaImporter().import_fatura_ozet),
        "3": ("Kargo Detay", PazaramaImporter().import_kargo_detay),
        "4": ("Komisyon Detay", PazaramaImporter().import_komisyon_detay),
        "5": ("Kargo Desi Fiyatları", PazaramaImporter().import_kargo_desi_fiyatlari),
    }

    if secim in metodlar:
        aciklama, metod = metodlar[secim]
        dosya = dosya_sor(aciklama)
        if dosya:
            metod(dosya)
    else:
        print("  [HATA] Gecersiz secim.")


# -------------------------------------------------------
# Flo
# -------------------------------------------------------
def flo_menusu():
    print("\n--- Flo ---")
    print("  1. Fatura Detay             → flo_fatura_detay")
    print("  2. Kargo Desi Fiyatları     → flo_kargo_desi_fiyatlari")
    secim = input("  Seçim (1-2): ").strip()

    metodlar = {
        "1": ("Fatura Detay", FloImporter().import_fatura_detay),
        "2": ("Kargo Desi Fiyatları", FloImporter().import_kargo_desi_fiyatlari),
    }

    if secim in metodlar:
        aciklama, metod = metodlar[secim]
        dosya = dosya_sor(aciklama)
        if dosya:
            metod(dosya)
    else:
        print("  [HATA] Gecersiz secim.")


# -------------------------------------------------------
# LCW
# -------------------------------------------------------
def lcw_menusu():
    print("\n--- LCW ---")
    print("  1. Kargo Faturası           → lcw_kargo_faturalari")
    print("  2. Komisyon Faturası        → lcw_komisyon_faturalari")
    print("  3. Kargo Desi Fiyatları     → lcw_kargo_desi_fiyatlari")
    secim = input("  Seçim (1-3): ").strip()

    metodlar = {
        "1": ("Kargo Faturası", LcwImporter().import_kargo_faturasi),
        "2": ("Komisyon Faturası", LcwImporter().import_komisyon_faturasi),
        "3": ("Kargo Desi Fiyatları", LcwImporter().import_kargo_desi_fiyatlari),
    }

    if secim in metodlar:
        aciklama, metod = metodlar[secim]
        dosya = dosya_sor(aciklama)
        if dosya:
            metod(dosya)
    else:
        print("  [HATA] Gecersiz secim.")


# -------------------------------------------------------
# Ana döngü
# -------------------------------------------------------
MENULAR = {
    "1": trendyol_menusu,
    "2": amazon_menusu,
    "3": hepsiburada_menusu,
    "4": n11_menusu,
    "5": pazarama_menusu,
    "6": flo_menusu,
    "7": lcw_menusu,
}

if __name__ == "__main__":
    while True:
        secim = ana_menu()
        if secim == "0":
            print("\n  Cikis yapiliyor. Gorusuruz!\n")
            break
        elif secim in MENULAR:
            MENULAR[secim]()
        else:
            print("  ❌ Geçersiz seçim, tekrar deneyin.")
